# Apollo Vault

Claude Code + Obsidian starter kit. Works in terminal, desktop app, or multiple instances at once.

## Quick Start

```bash
git clone https://github.com/mikedouzinas/apollo-vault.git my-vault
cd my-vault
./install.sh    # or: pnpm install
claude          # start Claude Code
```

Then run `/init-bootstrap`. It walks you through setup in a conversation, learns about you, and generates a CLAUDE.md tailored to how you work.

Optionally open the folder as a vault in [Obsidian](https://obsidian.md) for a visual interface alongside Claude Code.

## Key Features

**Self-maintaining CLAUDE.md** — Claude keeps its own reference tables updated. When it creates a file you'll need again, it adds the path. When you ask about something repeatedly, it suggests a shortcut. The config grows with your vault.

**Proactive context loading** — Claude checks recent vault changes at the start of every conversation. It loads relevant project files before you ask. You pick up where you left off.

**Council** (`/council [topic]`) — Think through hard problems from multiple perspectives. Spawns 2-4 independent agents with different worldviews (Pragmatist, Contrarian, Humanist by default). No agent knows the others exist, so you get genuine reasoning instead of performative debate. A synthesis agent finds the real tensions and insights. Perspectives are configurable.

**Chat import** — Drop exported conversations from ChatGPT, Gemini, or any LLM into `00_Inbox/` and run `/inbox`. Apollo extracts insights and files them into your vault.

**Daily/weekly reviews** — Customizable reflection commands. Daily review is a 5-10 minute check-in. Weekly synthesis runs an autonomous retrospective then walks you through planning.

## Folder Structure

```
apollo-vault/
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

| Command | What It Does |
|---------|-------------|
| `/init-bootstrap` | Setup wizard |
| `/council [topic]` | Multi-perspective reasoning |
| `/thinking-partner` | Collaborative thinking through questions |
| `/daily-review` | End-of-day reflection (5-10 min) |
| `/weekly-synthesis` | Two-phase weekly review |
| `/inbox` | Process and organize inbox files |
| `/research-assistant` | Deep research across your vault |
| `/add-frontmatter` | Add YAML metadata to notes |
| `/create-command` | Build custom commands |
| `/de-ai-ify` | Remove AI writing patterns |

## Setup Features

During `/init-bootstrap`, you can configure:

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
pnpm vault:stats              # Vault statistics
pnpm attachments:list         # Show unprocessed attachments
pnpm attachments:orphans      # Find unreferenced files
pnpm attachments:sizes        # Find large files
```

## Advanced Setup

### iCloud Access

During setup, Apollo offers to configure your vault in iCloud so you can access it from any Mac running Claude Code.

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
