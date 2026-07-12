#!/usr/bin/env python3
# Re-speak the last assistant turn of a transcript through the Kokoro server,
# interrupting whatever is currently playing. Usage: replay.py <transcript.jsonl>
# Self-contained (no import of the hook module).
import sys, os, re, json, urllib.request

def last_assistant_text(tpath):
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
        is_tr = isinstance(c, list) and any(isinstance(b, dict) and b.get("type") == "tool_result" for b in c)
        has_text = (isinstance(c, str) and c.strip()) or (
            isinstance(c, list) and any(isinstance(b, dict) and b.get("type") == "text" for b in c))
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

# Words the phonemizer gets wrong. Respell them the way they should SOUND.
# Left side is a regex, right side is what gets spoken. Add freely.
PRONOUNCE = [
    (r"\br[e\u00e9]sum[e\u00e9]s\b", "rezoomays"),
    (r"\br[e\u00e9]sum[e\u00e9]\b",  "rezoomay"),
    (r"\bresumes\b",       "rezoomays"),
    (r"\bresume\b",        "rezoomay"),   # the CV. Collides with the verb
    (r"\bTTS\b",           "T T S"),      # ("resume playback"), rare here.
    (r"\biOS\b",           "eye O S"),
    (r"\bCLI\b",           "C L I"),
    (r"\bLLM(s?)\b",       r"L L M\1"),
    (r"\bJSON\b",          "jayson"),
    (r"\be\.g\.",          "for example"),
    (r"\bi\.e\.",          "that is"),
    (r"\bvs\.",            "versus"),     # must precede the bare form
    (r"\bvs\b",            "versus"),
    (r"\betc\.",           "etcetera"),
]

_URL = re.compile(r"\b([a-zA-Z0-9][\w-]*)\.(com|org|net|io|dev|ai|co|app|edu|gov)((?:/[\w\-./]*)?)")

def _say_url(m):
    """mikeveson.com/the-web -> 'mikeveson dot com slash the web'.

    Without this the period reads as a sentence break, so you hear
    'mikeveson ... com', and the path is never spoken at all.
    """
    host, tld, path = m.group(1), m.group(2), m.group(3) or ""
    out = "%s dot %s" % (host, tld)
    if path:
        for seg in path.strip("/").split("/"):
            if seg:
                out += " slash " + seg.replace("-", " ").replace("_", " ")
    return out

# GREEK_INTERIM: Kokoro has no Greek. Fed native script, espeak spells the letters
# out one by one (a short sentence became 14 seconds of alphabet). Until Greek is
# routed to macOS `say -v Melina`, drop it from the spoken stream rather than
# recite it. See harlequin#122.
_GREEK = re.compile(r"[\u0370-\u03ff\u1f00-\u1fff]")

def normalize(t):
    """Make text speakable: expand URLs, respell what the phonemizer mangles."""
    if _GREEK.search(t):
        t = " ".join(w for w in t.split() if not _GREEK.search(w))
    t = _URL.sub(_say_url, t)
    for pat, rep in PRONOUNCE:
        t = re.sub(pat, rep, t, flags=re.IGNORECASE)
    return re.sub(r"\s+", " ", t)

def clean(t):
    t = re.sub(r"```.*?```", " ", t, flags=re.DOTALL)
    kept = []
    for ln in t.split("\n"):
        if re.search(r"[─━—]{3,}", ln):
            continue
        kept.append(ln.replace("★", ""))
    t = "\n".join(kept)
    t = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", t)
    t = re.sub(r"`([^`]*)`", r"\1", t)
    t = re.sub(r"\*\*([^*]+)\*\*", r"\1", t)
    t = re.sub(r"\*([^*]+)\*", r"\1", t)
    t = re.sub(r"^#+\s*", "", t, flags=re.MULTILINE)
    t = re.sub(r"^\s*[-*]\s+", "", t, flags=re.MULTILINE)
    t = re.sub(r"^\s*>\s?", "", t, flags=re.MULTILINE)
    t = re.sub(r"\n{2,}", ". ", t)
    t = re.sub(r"\s+", " ", t)
    return normalize(t.strip())

def post(path, data=b""):
    try:
        urllib.request.urlopen(
            urllib.request.Request("http://127.0.0.1:8765" + path, data=data, method="POST"),
            timeout=3)
    except Exception:
        pass

if __name__ == "__main__":
    if len(sys.argv) < 2 or not os.path.exists(sys.argv[1]):
        sys.exit(0)
    text = last_assistant_text(sys.argv[1])
    if not text:
        sys.exit(0)
    spoken = clean(text)[:9000].strip()
    if not spoken:
        sys.exit(0)
    if os.environ.get("TTS_DRY"):
        print("would speak:", spoken[:160]); sys.exit(0)
    post("/stop")
    post("/speak", spoken.encode("utf-8"))
