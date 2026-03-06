# Apollo Vault

Your Obsidian vault, but it thinks.

## What Is This?

Apollo Vault is a Claude Code + Obsidian starter kit that makes your vault intelligent. It's not just a folder structure. Claude proactively loads context from your vault, maintains its own reference system, and grows smarter as you use it.

Works in Claude Code terminal, Claude Code desktop app, or multiple instances simultaneously.

## Quick Start

### 1. Clone and Install

```bash
git clone https://github.com/mikedouzinas/apollo-vault.git my-vault
cd my-vault
./install.sh
```

Or manually:

```bash
pnpm install
mkdir -p 05_Attachments/Organized
```

### 2. Open in Obsidian (Recommended)

Download [Obsidian](https://obsidian.md) and open this folder as a vault. This gives you a visual interface alongside Claude Code.

### 3. Start Claude Code

```bash
claude
```

### 4. Run Setup

```
/init-bootstrap
```

This walks you through everything in a real conversation: who you are, how you work, what features you want. It generates a personalized CLAUDE.md that teaches Claude about your vault.

## What Makes Apollo Different

### Your CLAUDE.md Is Alive

Most setups generate a static config file. Apollo's CLAUDE.md is a living document that Claude actively maintains. When Claude creates a new important file, it adds the path to the reference table. When you ask about something repeatedly, it suggests adding a quick-start trigger. The file grows with your vault.

### Proactive Context Loading

Claude doesn't wait for you to explain what you're working on. At the start of every conversation, it checks recent vault changes, loads relevant project context, and references what you were doing yesterday. You pick up where you left off.

### The Council

Think through hard problems from multiple genuine perspectives.

```
/council Should I take the job offer or stay at my current company?
```

Apollo spawns 2-4 independent agents, each with a different worldview (Pragmatist, Contrarian, Humanist by default). No agent knows about the others. This produces genuine reasoning, not performative debate. A synthesis agent then finds where they agree, where they genuinely disagree, and what insight emerges from the tension.

Custom perspectives are configurable. A founder might want "Customer / Engineer / Investor." A writer might want "Editor / Reader / Subject Expert."

### Bring Your History

Drop exported conversations from ChatGPT, Gemini, or any other LLM into your inbox. Apollo processes them, extracts key insights, and files them into your vault. Months of thinking from other tools become searchable, connected knowledge.

```
# Drop chat exports into 00_Inbox/, then:
/inbox
```

### Setup in One Conversation

The setup wizard (`/init-bootstrap`) is a real dialogue. It researches your public profile, asks about your workflow, imports your existing notes, and configures everything based on the conversation. Not a form. Not a checklist.

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

## Philosophy

AI amplifies thinking, not just writing. Your vault is your second brain. Apollo makes it intelligent.

The key principles:
- **Proactive, not reactive** - Claude loads context before you ask
- **Living, not static** - CLAUDE.md grows with your vault
- **Genuine, not performative** - The council produces real reasoning
- **Yours, not generic** - Everything is configured to how you actually work

## Built On

Built on ideas from [Claudesidian](https://github.com/heyitsnoah/claudesidian) by Noah Brier and the team at [Alephic](https://alephic.com). Apollo adds vault intelligence, the council command, chat import, and a self-maintaining CLAUDE.md system.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT - Make it your own.
