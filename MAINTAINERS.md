# Iris Vault Repository Management

**This CLAUDE.md is for maintaining the iris-vault repository itself.**

**If you're a user setting up your own vault:** you do not need this file, or any command.
Open the folder in the Claude app and say hi. The FIRST RUN block in `CLAUDE.md` runs the
setup as a conversation and writes your answers into `CLAUDE.md` itself.

---

## Repository Overview

Iris Vault is a Claude Code + Obsidian starter kit that makes your vault intelligent. Built on ideas from [Claudesidian](https://github.com/heyitsnoah/claudesidian) by Noah Brier.

## Version Management

This project uses:
- **Semantic Versioning** (MAJOR.MINOR.PATCH)
- **Keep a Changelog** format in CHANGELOG.md
- **Conventional Commits** for commit messages

### Commit Message Format

```
feat: add new feature
fix: resolve bug
docs: update documentation
chore: maintenance tasks
```

### Release Process

1. Update version in `package.json`
2. Move "Unreleased" items to new version in `CHANGELOG.md`
3. Commit: `git commit -m "chore: release vX.Y.Z"`
4. Tag: `git tag vX.Y.Z`
5. Push: `git push && git push --tags`

## Project Structure

```
iris-vault/
├── .claude/
│   ├── commands/         # Slash commands
│   ├── mcp-servers/      # MCP server implementations
│   ├── claude_config.json
│   ├── settings.json     # Hooks configuration
│   └── settings.local.json
├── .scripts/             # Helper bash/js scripts
├── 00_Inbox/ through 06_Metadata/  # Template PARA folders
├── CHANGELOG.md
├── CONTRIBUTING.md
├── README.md
├── install.sh
└── package.json
```

## Key Components

### Commands
- `council` - Multi-perspective reasoning with independent agents
- `daily-review` - Customizable end-of-day reflection
- `weekly-synthesis` - Two-phase weekly review
- `inbox-processor` - File processing with chat export support
- Other commands for thinking, research, and vault management

### Scripts
- Vault statistics
- Web scraping (Firecrawl)
- Link maintenance
- Transcript extraction

### MCP Servers
- Gemini Vision for image/PDF/video analysis (optional)

## Development Guidelines

### Adding New Features

1. Create feature in appropriate directory
2. Update CHANGELOG.md under "Unreleased"
3. Update README if user-facing
4. Test with fresh clone

### Testing Changes

```bash
git clone https://github.com/mikedouzinas/iris-vault.git test-vault
cd test-vault
claude   # then say hi, and check that the FIRST RUN conversation opens on its own
pnpm docs:check
./.scripts/make-distributable.sh --out /tmp/iris-vault.zip
```

### Important Files

- **CLAUDE.md** - The product. Its FIRST RUN block is the entire setup experience.
- **START HERE.md** - The non-technical door. Same five steps as the README.
- **.scripts/docs-check.mjs** - Fails if any onboarding doc tells the reader to run a command first.
- **.scripts/make-distributable.sh** - Builds the sendable zip. The zip is never hand-assembled.
- **package.json** - Version and dependencies

## Note for Contributors

Setup is a conversation, not a wizard. `FIRST_RUN` exists in a fresh copy; `CLAUDE.md` tells Iris
to greet the person, ask four questions, write the answers over the FIRST RUN block, and delete
`FIRST_RUN`. Nothing asks them to type a command, and four documents used to disagree about that.
`pnpm docs:check` is what keeps them agreeing.
