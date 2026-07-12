#!/usr/bin/env python3
"""
Kokoro TTS server — model stays resident; the Claude Code hook POSTs text here.

Fixes:
  - PREFETCH pipeline: a producer thread synthesizes sentences ahead into a queue
    while the player plays, so there's no synthesis gap between sentences.
  - SILENCE TRIM: leading/trailing near-silence is trimmed per chunk (tighter).
  - RE-FIRE GUARD: a /speak whose text equals or is a prefix of what's currently
    playing is IGNORED, so a duplicate/partial hook fire can't cut off playback.
    Only genuinely new/longer text interrupts.

Endpoints (localhost): POST /speak (body=text), /stop, /voice (body=name)
"""
import os, re, time, tempfile, subprocess, threading, queue, http.server
import numpy as np
from kokoro_onnx import Kokoro
import soundfile as sf

HERE = os.path.expanduser("~/.claude/hooks/voice")
VOICE = "af_heart"     # natural default. Others: af_bella, af_nicole, bf_emma (British), am_michael, bm_george
SPEED = 1.0
LANG = "en-us"
PORT = 8765
LOG = os.path.expanduser("~/.claude/hooks/voice/tts.log")

def log(msg):
    """The server used to fail SILENTLY: /speak returned 204, the playback thread
    died, and the hook logged a cheerful 'sent N chars to kokoro'. Every failure
    looked exactly like success. Nothing below is allowed to be quiet again."""
    try:
        with open(LOG, "a") as f:
            f.write("[kokoro] " + msg + "\n")
    except Exception:
        pass

kokoro = Kokoro(os.path.join(HERE, "kokoro-v1.0.onnx"), os.path.join(HERE, "voices-v1.0.bin"))

_lock = threading.Lock()
_gen = 0
_current = ""
_pending = None
_pending_id = 0
DEBOUNCE = 0.35   # coalesce hook double-fires within this window; play only the fullest

GREEK_RE = re.compile(r"[\u0370-\u03ff\u1f00-\u1fff]")
GREEK_VOICE = "Melina"      # macOS `say`, el_GR. Kokoro has no Greek at all.

def _sentences(text):
    parts = re.split(r'(?<=[.!?])\s+', text)
    out = []
    for p in parts:
        p = p.strip()
        if not p:
            continue
        if out and len(out[-1]) < 60:          # merge short fragments -> fewer boundaries
            out[-1] += " " + p
        else:
            out.append(p)
    return out or [text]

def _runs(text):
    """Split into ('el'|'en', chunk) runs, in order.

    Greek and English can alternate inside one reply. Each run is routed to the
    engine that can actually pronounce it, and both engines write FILES into the
    same playback queue -- so ordering, interruption and ducking keep working
    unchanged. Punctuation attaches to the run it follows.
    """
    toks = re.findall(r"\S+\s*", text)
    runs, cur, lang = [], [], None
    for t in toks:
        l = "el" if GREEK_RE.search(t) else ("en" if re.search(r"[A-Za-z]", t) else lang or "en")
        if l != lang and cur:
            runs.append((lang, "".join(cur).strip())); cur = []
        lang = l
        cur.append(t)
    if cur:
        runs.append((lang, "".join(cur).strip()))
    return [(l, c) for l, c in runs if c]

def _synth(lang, chunk):
    """Render one chunk to a file. Returns a path, or None."""
    fd, path = tempfile.mkstemp(suffix=".aiff" if lang == "el" else ".wav", dir="/tmp")
    os.close(fd)
    try:
        if lang == "el":
            # `say -o` writes a file instead of playing, so Greek lands in the SAME
            # queue as Kokoro's WAVs. One player, one ordering.
            subprocess.run(["say", "-v", GREEK_VOICE, "-o", path, chunk],
                           check=True, stderr=subprocess.DEVNULL, timeout=30)
        else:
            samples, sr = kokoro.create(chunk, voice=VOICE, speed=SPEED, lang=LANG)
            sf.write(path, _trim(samples, sr), sr)
        return path
    except Exception as e:
        log("SYNTH FAILED (%s, %d chars): %r" % (lang, len(chunk), e))
        try: os.remove(path)
        except Exception: pass
        return None

def _trim(samples, sr, thresh=0.006):
    mono = samples.mean(axis=1) if samples.ndim > 1 else samples
    idx = np.where(np.abs(mono) > thresh)[0]
    if len(idx) == 0:
        return samples
    start = max(0, idx[0] - int(0.01 * sr))
    end = min(len(samples), idx[-1] + int(0.03 * sr))
    return samples[start:end]

DUCK_TO = 30                       # percent, while speaking
DUCK_APPS = ("Spotify", "Music")
_ducked = {}

def _osa(script, timeout=5):
    """Run AppleScript, never raise, never block forever."""
    try:
        r = subprocess.run(["osascript", "-e", script], capture_output=True,
                           text=True, timeout=timeout)
        return r.stdout.strip() if r.returncode == 0 else None
    except Exception as e:
        log("osascript failed: %r" % e)
        return None

def duck():
    """Lower music volume while speaking. Volume only — never play/pause state.

    `tell application "X" to ...` LAUNCHES X if it isn't running (a bare volume
    read on a closed Spotify took 3.8s and opened the app). The `is running`
    guard is what keeps this from launching apps and stalling playback.
    """
    _ducked.clear()
    for app in DUCK_APPS:
        v = _osa('if application "%s" is running then '
                 'tell application "%s" to get sound volume' % (app, app))
        if not v or not v.isdigit():
            continue                      # not running -> nothing to duck
        v = int(v)
        if v > DUCK_TO:
            _ducked[app] = v
            _osa('if application "%s" is running then '
                 'tell application "%s" to set sound volume to %d' % (app, app, DUCK_TO))

def unduck():
    for app, v in list(_ducked.items()):
        _osa('if application "%s" is running then '
             'tell application "%s" to set sound volume to %d' % (app, app, v))
    _ducked.clear()

def _run(text, my_gen):
    # Ducking must NEVER be able to prevent speech. It is a nicety; the voice is
    # the product. Any failure here gets logged and stepped over.
    try:
        duck()
    except Exception as e:
        log("duck failed (continuing): %r" % e)
    try:
        _play(text, my_gen)
    except Exception as e:
        log("PLAYBACK FAILED: %r" % e)
    finally:
        if my_gen == _gen:      # only restore if we weren't superseded mid-speech
            try:
                unduck()
            except Exception as e:
                log("unduck failed: %r" % e)

def _play(text, my_gen):
    q = queue.Queue(maxsize=4)
    def producer():
        # Route each language run to the engine that can pronounce it, then split
        # long English runs into sentences so the prefetch stays responsive.
        for lang, run in _runs(text):
            chunks = [run] if lang == "el" else _sentences(run)
            for chunk in chunks:
                if my_gen != _gen:
                    q.put(None); return
                path = _synth(lang, chunk)
                if path is None:
                    continue
                if my_gen != _gen:
                    try: os.remove(path)
                    except Exception: pass
                    q.put(None); return
                q.put(path)
        q.put(None)
    threading.Thread(target=producer, daemon=True).start()
    while True:
        path = q.get()
        if path is None:
            break
        if my_gen != _gen:
            try: os.remove(path)
            except Exception: pass
            continue
        p = subprocess.Popen(["afplay", path])
        while p.poll() is None:
            if my_gen != _gen:
                p.terminate(); break
            threading.Event().wait(0.03)
        try: os.remove(path)
        except Exception: pass

def speak(text):
    # Debounced: rapid fires within DEBOUNCE coalesce; only the fullest text plays once.
    global _pending, _pending_id
    with _lock:
        if text == _current or (_current and _current.startswith(text)):
            return                         # already playing this (or a superset)
        if _pending and _pending.startswith(text):
            return                         # a fuller version is already pending
        _pending = text                    # newest/fullest wins
        _pending_id += 1
        pid = _pending_id
    threading.Thread(target=_debounced_start, args=(pid,), daemon=True).start()

def _debounced_start(pid):
    time.sleep(DEBOUNCE)
    global _gen, _current, _pending
    with _lock:
        if pid != _pending_id:             # a newer fire superseded this one
            return
        text = _pending
        _pending = None
        if not text or text == _current or (_current and _current.startswith(text)):
            return
        _gen += 1
        my_gen = _gen
        _current = text
    subprocess.run(["pkill", "-x", "afplay"], stderr=subprocess.DEVNULL)
    threading.Thread(target=_run, args=(text, my_gen), daemon=True).start()

def stop():
    global _gen, _current, _pending
    with _lock:
        _gen += 1
        _current = ""
        _pending = None
    subprocess.run(["pkill", "-x", "afplay"], stderr=subprocess.DEVNULL)
    unduck()

class H(http.server.BaseHTTPRequestHandler):
    def log_message(self, *a):
        pass
    def do_POST(self):
        global VOICE
        n = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(n).decode("utf-8", "ignore") if n else ""
        if self.path == "/speak" and body.strip():
            speak(body)
        elif self.path == "/stop":
            stop()
        elif self.path == "/voice" and body.strip():
            VOICE = body.strip()
        self.send_response(204)
        self.end_headers()

if __name__ == "__main__":
    # Fail LOUD on start. The duck()/unduck() NameError that broke this server
    # for a full morning was invisible because nothing ever checked and nothing
    # ever logged. Synthesize one throwaway word: if the pipeline is broken, the
    # log says so at startup instead of after a day of silence.
    p = _synth("en", "ready")
    if p:
        os.remove(p)
        log("startup OK — voice=%s, port=%d" % (VOICE, PORT))
    else:
        log("STARTUP FAILED — synthesis is broken, speech will not work")
    http.server.HTTPServer(("127.0.0.1", PORT), H).serve_forever()
