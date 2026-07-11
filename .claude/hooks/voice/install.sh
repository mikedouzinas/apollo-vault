#!/bin/bash
# Iris Voice — make Claude Code read its replies aloud, in a local neural voice.
#
#   ./.claude/hooks/voice/install.sh
#
# What you get:
#   - Claude speaks every reply, in full (including prose written around tool calls)
#   - A local neural voice (Kokoro). No API key, no cloud, no per-word billing.
#   - Music ducks while it speaks, and comes back after
#   - ttson / ttsoff / ttsstop / ttsreplay on your PATH
#
# macOS only for now (uses `afplay` and launchd). PRs welcome for Linux.
set -euo pipefail

VOICE_DIR="$HOME/.claude/hooks/voice"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$HOME/.local/bin"
PY="$(command -v python3)"

echo "==> Installing Iris Voice"

if [[ "$(uname)" != "Darwin" ]]; then
  echo "!! macOS only right now (needs afplay + launchd). Aborting." >&2
  exit 1
fi

# 1. Files
mkdir -p "$VOICE_DIR" "$BIN"
cp "$SRC"/{speak-response.py,kokoro_server.py,replay.py} "$VOICE_DIR/"
cp "$SRC"/bin/* "$BIN/"
chmod +x "$BIN"/tts* "$VOICE_DIR"/*.py

# 2. Dependencies
echo "==> Installing espeak-ng (phonemizer backend)"
command -v espeak-ng >/dev/null || brew install espeak-ng

echo "==> Installing Python deps"
"$PY" -m pip install --quiet --upgrade kokoro-onnx soundfile numpy

# 3. Model weights (~340MB, downloaded once)
cd "$VOICE_DIR"
[[ -f kokoro-v1.0.onnx ]] || {
  echo "==> Downloading Kokoro model (310MB)"
  curl -fL -o kokoro-v1.0.onnx \
    https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/kokoro-v1.0.onnx
}
[[ -f voices-v1.0.bin ]] || {
  echo "==> Downloading voices (27MB)"
  curl -fL -o voices-v1.0.bin \
    https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/voices-v1.0.bin
}

# 4. Keep the TTS server resident so speech starts instantly
PLIST="$HOME/Library/LaunchAgents/com.iris.voice.plist"
cat > "$PLIST" <<PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>com.iris.voice</string>
  <key>ProgramArguments</key>
  <array><string>$PY</string><string>$VOICE_DIR/kokoro_server.py</string></array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>StandardErrorPath</key><string>$VOICE_DIR/server.log</string>
</dict></plist>
PLISTEOF

launchctl bootout "gui/$(id -u)/com.iris.voice" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"

echo
echo "==> Almost done. Add the Stop hook to ~/.claude/settings.json:"
echo
cat <<HOOKEOF
  "hooks": {
    "Stop": [
      { "hooks": [ { "type": "command", "command": "$PY $VOICE_DIR/speak-response.py" } ] }
    ]
  }
HOOKEOF
echo
echo "   (Use the FULL path to python — the hook runs with a bare PATH and"
echo "    a plain 'python3' will silently fail.)"
echo
echo "==> Then, in any Claude Code session:"
echo "   ttsoff    mute        ttson       unmute"
echo "   ttsstop   shut it up  ttsreplay   re-speak the last reply"
echo
echo "==> Change the voice: edit VOICE in $VOICE_DIR/kokoro_server.py"
echo "   af_heart (default) · af_bella · af_nicole · bf_emma (British) · am_michael · bm_george"
echo
echo "Done. Claude will speak its next reply."
