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
    return t.strip()

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
