# Iris Vault

Claude Code + Obsidian starter kit. Works in terminal, desktop app, or multiple instances at once.

## Start here

1. Download the vault: **[mikeveson.com/vault](https://mikeveson.com/vault)**
2. Unzip it. Put the folder anywhere you like.
3. Get the Claude app: [claude.com/download](https://claude.com/download). Sign in.
4. Click the **Code** tab, then **Select folder**, and pick that folder.
5. Say **hi**.

Iris opens the conversation, explains what the folder is, asks you a few questions, and writes your answers into `CLAUDE.md`. It takes a couple of minutes and there is nothing to install.

The longer version of the same five steps, written for someone who has never used any of this, is `START HERE.md` inside the folder.

Claude Code requires a paid Claude plan (Pro, Max, Team, or Enterprise).

## Or skip the download

If you already have the Claude app, there is nothing to download at all.

1. Make a new empty folder anywhere, and name it whatever you want.
2. Open the Claude app, click the **Code** tab, then **Select folder**, and pick it.
3. Send this as your first message:

> Set this folder up as my Iris vault by following mikeveson.com/setup

Claude fetches the vault into that folder and then introduces itself. Same result as the five steps above, with no zip file and nothing to unzip.

This route always gets the current version, because it is fetched when you set up rather than whenever you happened to download.

<!-- docs-check: allow-commands -->

## If you use a terminal

Clone instead of downloading. Same vault, same first conversation.

```bash
git clone https://github.com/mikedouzinas/iris-vault.git my-vault
cd my-vault
git remote remove origin    # so your notes never push to someone else's repo
claude
```

Then say **hi**. There is no setup command to run.

`./install.sh` is optional and nothing on day one needs it. It sets up the Gemini Vision MCP server and checks for optional command-line tools.

Optionally open the folder as a vault in [Obsidian](https://obsidian.md) for a visual interface alongside Claude Code.

## Key Features

**Self-maintaining CLAUDE.md** — Claude keeps its own reference tables updated. When it creates a file you'll need again, it adds the path. When you ask about something repeatedly, it suggests a shortcut. The config grows with your vault.

**Proactive context loading** — Claude checks recent vault changes at the start of every conversation. It loads relevant project files before you ask. You pick up where you left off.

**Council** (`/council [topic]`) — Think through hard problems from multiple perspectives. Spawns 2-4 independent agents with different worldviews (Pragmatist, Contrarian, Humanist by default). No agent knows the others exist, so you get genuine reasoning instead of performative debate. A synthesis agent finds the real tensions and insights. Perspectives are configurable.

**Chat import** — Drop exported conversations from ChatGPT, Gemini, or any LLM into `00_Inbox/` and run `/inbox`. Iris extracts insights and files them into your vault.

**Voice** (`./.claude/hooks/voice/install.sh`) — Your vault reads itself to you. Claude speaks its replies aloud in a local neural voice: no API key, no cloud, no per-word billing, works on a subscription. It reads the *whole* reply (including prose written around tool calls, which the naive version silently truncates), synthesizes ahead so there's no gap between sentences, ducks your music while it talks, and stops on command. Built during a concussion, when I had to minimize screen time and listening cost me no recovery. Take a walk and keep working. See [`.claude/hooks/voice/`](.claude/hooks/voice/).

**Daily/weekly reviews** — Customizable reflection commands. Daily review is a 5-10 minute check-in. Weekly synthesis runs an autonomous retrospective then walks you through planning.

## Folder Structure

```
iris-vault/
├── 00_Inbox/           # Drop files here for processing
├── 01_Projects/        # Active, time-bound initiatives
├── 02_Areas/           # Ongoing responsibilities
├── 03_Resources/       # Reference materials
├── 04_Archive/         # Completed or inactive items
├── 05_Attachments/     # Images, PDFs, files
├── 06_Metadata/
│   ├── Daily Journal/  # Conversation insights (opt-in)
│   ├── Weekly Reviews/ # Weekly synthesis outputs
│   ├── Council/        # Multi-perspective reasoning sessions
│   ├── Reference/      # Guides and documentation
│   └── Templates/      # Reusable note templates
└── .claude/            # Commands, config, MCP servers
```

## Commands

Every one of these is optional. Iris does the work when you ask for it in plain words; the commands are shortcuts, not the interface.

| Command | What It Does |
|---------|-------------|
| `/council [topic]` | Multi-perspective reasoning |
| `/thinking-partner` | Collaborative thinking through questions |
| `/daily-review` | End-of-day reflection (5-10 min) |
| `/weekly-synthesis` | Two-phase weekly review |
| `/inbox` | Process and organize inbox files |
| `/research-assistant` | Deep research across your vault |
| `/add-frontmatter` | Add YAML metadata to notes |
| `/create-command` | Build custom commands |
| `/de-ai-ify` | Remove AI writing patterns |

## Optional Extras

Ask Iris for any of these whenever you want them. None of them are part of day one.

- **Daily Journal** - Auto-capture insights from conversations
- **Weekly Review** - Pattern recognition and planning ritual
- **Daily Review** - Quick end-of-day check-ins
- **Auto-sync** - Local git commits on every edit (no push)
- **Council Perspectives** - Custom reasoning angles
- **Quick-start Triggers** - Shortcut phrases that load context
- **Gemini Vision** - Image/PDF/video analysis (free API key)
- **Firecrawl** - Save web pages as searchable markdown

## Helper Scripts

```bash
pnpm docs:check               # Onboarding docs still tell one story
pnpm vault:stats              # Vault statistics
pnpm attachments:list         # Show unprocessed attachments
pnpm attachments:orphans      # Find unreferenced files
pnpm attachments:sizes        # Find large files
```

## Advanced Setup

### iCloud Access

Ask Iris to move your vault into iCloud and you can reach it from any Mac running Claude Code.

### Mobile Access

1. Set up a small server (mini PC, cloud VPS, or home server)
2. Install Tailscale for secure VPN access
3. Clone your vault to the server
4. Use an SSH client on mobile
5. Run Claude Code remotely

### NanoClaw (Experimental)

An always-on background agent accessible via Telegram. Requires Docker and technical setup. Currently unstable. Mentioned during setup for those interested.

## Credits

Built on ideas from [Claudesidian](https://github.com/heyitsnoah/claudesidian) by Noah Brier and the team at [Alephic](https://alephic.com).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT - Make it your own.
