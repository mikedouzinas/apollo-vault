# Iris Voice

**Your vault reads itself to you.**

Claude Code speaks its replies aloud in a local neural voice. No API key, no cloud round-trip, no per-word billing — it runs entirely on your machine and works on a Claude subscription, because it's just a hook watching the transcript.

```bash
./.claude/hooks/voice/install.sh
```

## Why

Built during a concussion, when I had to minimize screen time and listening cost me no recovery.

That turns out not to be a niche case. You can take a walk and keep working. You can close your eyes and keep working. Screens have been the only channel into these tools for a long time, and they don't have to be.

## What you get

- **The whole reply, not a fragment.** Claude Code's Stop hook can fire *before* the final text block is flushed to the transcript, so the naive version reads only the prose before the first tool call and then stops mid-thought. This one spawns a detached worker that polls until the turn's text stops changing, then speaks all of it. **You don't have to change how Claude structures its answers.**
- **A voice worth listening to.** [Kokoro](https://github.com/thewh1teagle/kokoro-onnx) runs locally. Several voices ship with it; swap with one line.
- **No dead air between sentences.** A producer thread synthesizes the next sentence while the current one plays, and near-silence is trimmed from each chunk. The naive version has a noticeable gap at every period.
- **Music ducks.** Spotify and Music drop while Claude talks and return to their exact prior volume after. It never touches play/pause — if nothing was playing, nothing is touched.
- **Interruptible.** `ttsstop`, or the hotkey of your choice.
- **Coalesced re-fires.** The hook can fire twice in quick succession; a debounce means only the fullest version speaks, so you never get cut off mid-word by your own second firing.

## Controls

| Command | What it does |
|---|---|
| `ttsoff` | Mute. Use it before anything sensitive. |
| `ttson` | Unmute. |
| `ttsstop` | Shut up right now. |
| `ttsreplay` | Re-speak the last reply (stops whatever's playing first). |

Running several Claude Code sessions at once? `ttsstop` silences all of them; `ttsreplay` inside a session re-speaks *that* session's last reply. For global hotkeys, point something like [skhd](https://github.com/koekeishiya/skhd) at `ttsstop` and `ttsreplay`.

## Changing the voice

Edit `VOICE` in `~/.claude/hooks/voice/kokoro_server.py`:

`af_heart` (default) · `af_bella` · `af_nicole` · `bf_emma` (British) · `am_michael` · `bm_george`

Then `launchctl kickstart -k gui/$(id -u)/com.iris.voice`.

## How it works

```
Claude finishes a turn
   └── Stop hook fires (returns instantly, spawns a detached worker)
         └── worker polls the transcript until the text stops growing
               └── strips code blocks, markdown, rule lines
                     └── POST → local Kokoro server (resident, model already loaded)
                           └── debounce → synthesize ahead → afplay
```

The server stays resident via a launchd agent, so the 310MB model is loaded once at login rather than on every reply. That's the difference between speech starting in ~200ms and ~8 seconds.

## Requirements

macOS (uses `afplay` and `launchd`), Homebrew, Python 3. ~340MB of model weights, downloaded once.

Linux support is a welcome PR — the only Mac-specific parts are the audio player, the launchd agent, and the AppleScript ducking.
