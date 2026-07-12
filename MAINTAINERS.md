# Apollo Vault Repository Management

**This CLAUDE.md is for maintaining the apollo-vault repository itself.**

**If you're a user setting up your own vault:**
- Run `/init-bootstrap` to create your personalized CLAUDE.md
- That command will overwrite this file with your custom configuration
- This file is only for contributors working on the apollo-vault project

---

## Repository Overview

Apollo Vault is a Claude Code + Obsidian starter kit that makes your vault intelligent. Built on ideas from [Claudesidian](https://github.com/heyitsnoah/claudesidian) by Noah Brier.

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
apollo-vault/
├── .claude/
│   ├── commands/         # Slash commands
│   ├── mcp-servers/      # MCP server implementations
│   ├── claude_config.json
│   ├── settings.json     # Hooks configuration
│   └── settings.local.json
├── .scripts/             # Helper bash/js scripts
├── 00_Inbox/ through 06_Metadata/  # Template PARA folders
├── APOLLO-BOOTSTRAP.md   # Template for user CLAUDE.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── README.md
├── install.sh
└── package.json
```

## Key Components

### Commands
- `init-bootstrap` - Main setup wizard that overwrites this file
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
git clone https://github.com/mikedouzinas/apollo-vault.git test-vault
cd test-vault
pnpm install
claude  # Then run /init-bootstrap
```

### Important Files

- **APOLLO-BOOTSTRAP.md** - Template that init-bootstrap uses to generate user CLAUDE.md
- **package.json** - Version and dependencies
- **.claude/commands/init-bootstrap.md** - The setup wizard (most important command)

## Note for Contributors

Users run `/init-bootstrap` which:
1. Reads APOLLO-BOOTSTRAP.md as template
2. Asks personalization questions in conversation
3. Overwrites this CLAUDE.md with user's configuration
4. Sets up their personal vault

This separation ensures repo maintenance instructions don't interfere with user vault configuration.
