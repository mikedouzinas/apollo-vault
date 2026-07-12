#!/usr/bin/env python3
"""
Claude Code Stop hook: read the full final assistant turn aloud via macOS `say`.
Spoken-response ("Jarvis") mode for terminal Claude Code — Max sub, no API cost.

Why this is robust:
  The Stop hook can fire a moment BEFORE Claude's final text block is flushed to
  the transcript, so a naive read catches only the text before the last tool call.
  Fix: the hook returns instantly and spawns a DETACHED worker that polls the
  transcript until the current turn's text is STABLE (finished flushing), then
  speaks the whole thing. No constraint on how the reply is structured.

Controls:
  - DISABLE:  create  ~/.claude/hooks/voice/tts-off   (or run `ttsoff`)
  - ENABLE:   delete it            (or run `ttson`)
  - STOP current speech:  `ttsstop`   (or  pkill -x say)
  - CHANGE VOICE: edit VOICE below (list: `say -v '?'`)
  - DRY RUN (print, no audio, synchronous):  TTS_DRY=1
"""
import sys, json, re, subprocess, os, time

USE_KOKORO = True  # local neural voice via the Kokoro server (best quality). False -> say/personal
KOKORO_URL = "http://127.0.0.1:8765/speak"
VOICE = "Moira"    # fallback `say` voice (Irish) if Kokoro is off/down
USE_PERSONAL = False # use Mike's Voice (saymike helper) as the fallback instead of `say`
PERSONAL_BIN = os.path.expanduser("~/.claude/hooks/saymike")
MAX_CHARS = 9000

def log(msg):
    try:
        with open(os.path.expanduser("~/.claude/hooks/voice/tts.log"), "a") as f:
            f.write(msg + "\n")
    except Exception:
        pass

def muted():
    return os.path.exists(os.path.expanduser("~/.claude/hooks/voice/tts-off"))

def suppressed():
    """One-shot mute, set by ttsreplay/ttsstop.

    Running `!ttsreplay` inside a session is itself a user turn, so Claude answers
    it and THIS hook fires and speaks that answer, cutting off the replay that was
    just asked for. The flag consumes exactly that one Stop event. Time-limited so a
    stale flag can never silently mute a later reply.
    """
    f = os.path.expanduser("~/.claude/hooks/voice/suppress-next")
    if not os.path.exists(f):
        return False
    try:
        fresh = (time.time() - os.path.getmtime(f)) < 120
    except Exception:
        fresh = False
    try:
        os.remove(f)          # consume it either way
    except Exception:
        pass
    return fresh

def current_turn_text(tpath):
    """All assistant text since the last genuine human message (reads around tool calls)."""
    try:
        with open(tpath) as f:
            entries = []
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    entries.append(json.loads(line))
                except Exception:
                    continue
    except Exception:
        return None
    last_user = -1
    for i, e in enumerate(entries):
        if e.get("type") != "user":
            continue
        c = e.get("message", {}).get("content")
        is_tr = isinstance(c, list) and any(
            isinstance(b, dict) and b.get("type") == "tool_result" for b in c)
        has_text = (isinstance(c, str) and c.strip()) or (
            isinstance(c, list) and any(
                isinstance(b, dict) and b.get("type") == "text" for b in c))
        if is_tr and not has_text:
            continue
        last_user = i
    parts = []
    for e in entries[last_user + 1:]:
        if e.get("type") != "assistant":
            continue
        if e.get("message", {}).get("role") != "assistant":
            continue
        c = e.get("message", {}).get("content", [])
        if isinstance(c, list):
            for b in c:
                if isinstance(b, dict) and b.get("type") == "text":
                    t = b.get("text", "").strip()
                    if t:
                        parts.append(t)
        elif isinstance(c, str) and c.strip():
            parts.append(c.strip())
    return "\n\n".join(parts) if parts else None

def clean(t):
    t = re.sub(r"```.*?```", " ", t, flags=re.DOTALL)          # skip code blocks
    kept = []
    for ln in t.split("\n"):
        if re.search(r"[─━—]{3,}", ln):                         # skip insight-box rules
            continue
        kept.append(ln.replace("★", ""))
    t = "\n".join(kept)
    t = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", t)              # links -> text
    t = re.sub(r"`([^`]*)`", r"\1", t)
    t = re.sub(r"\*\*([^*]+)\*\*", r"\1", t)
    t = re.sub(r"\*([^*]+)\*", r"\1", t)
    t = re.sub(r"^#+\s*", "", t, flags=re.MULTILINE)
    t = re.sub(r"^\s*[-*]\s+", "", t, flags=re.MULTILINE)
    t = re.sub(r"^\s*>\s?", "", t, flags=re.MULTILINE)
    t = re.sub(r"\n{2,}", ". ", t)
    t = re.sub(r"\s+", " ", t)
    return t.strip()

def worker(tpath):
    """Wait until the turn's text stops growing (final block flushed), then speak."""
    prev, stable = None, 0
    for _ in range(24):                # up to ~3.6s
        txt = current_turn_text(tpath)
        if txt and txt == prev:
            stable += 1
            if stable >= 2:            # unchanged across 2 reads = done flushing
                break
        else:
            stable = 0
            prev = txt
        time.sleep(0.15)
    txt = prev
    if not txt:
        log("worker: no text"); return
    if muted():
        log("worker: muted mid-wait"); return
    spoken = clean(txt)[:MAX_CHARS].strip()
    if not spoken:
        log("worker: empty after clean"); return
    if USE_KOKORO:
        try:
            import urllib.request
            req = urllib.request.Request(KOKORO_URL, data=spoken.encode("utf-8"), method="POST")
            urllib.request.urlopen(req, timeout=3)
            log("worker: sent %d chars to kokoro" % len(spoken))
            return
        except Exception as e:
            log("kokoro unreachable (%r) -> fallback" % e)
    subprocess.run(["pkill", "-x", "say"], stderr=subprocess.DEVNULL)
    subprocess.run(["pkill", "-x", "saymike"], stderr=subprocess.DEVNULL)
    if USE_PERSONAL and os.path.exists(PERSONAL_BIN):
        subprocess.Popen([PERSONAL_BIN, spoken])
        log("worker: spoke %d chars (Mike's Voice)" % len(spoken))
    else:
        cmd = ["say"] + (["-v", VOICE] if VOICE else []) + [spoken]
        subprocess.Popen(cmd)
        log("worker: spoke %d chars (say/%s)" % (len(spoken), VOICE))

def main():
    # Worker mode (spawned detached): do the wait-and-speak.
    if os.environ.get("TTS_WORKER"):
        worker(os.environ.get("TTS_TPATH", ""))
        return

    # Hook mode: read stdin, spawn worker, return instantly (non-blocking).
    log("--- hook fired ---")
    if muted():
        log("muted (tts-off present)"); return
    if suppressed():
        log("suppressed (this turn was triggered by ttsreplay/ttsstop)"); return
    try:
        data = json.load(sys.stdin)
    except Exception as e:
        log("no/invalid stdin json: %r" % e); return
    tpath = data.get("transcript_path")
    if not tpath or not os.path.exists(tpath):
        log("transcript missing"); return

    if os.environ.get("TTS_DRY"):      # synchronous, print only (for testing)
        print(clean(current_turn_text(tpath) or "")[:MAX_CHARS].strip())
        return

    env = dict(os.environ, TTS_WORKER="1", TTS_TPATH=tpath)
    subprocess.Popen(
        [sys.executable, os.path.abspath(__file__)],
        env=env, stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        start_new_session=True,        # detach so it survives the hook returning
    )
    log("spawned worker")

if __name__ == "__main__":
    main()
