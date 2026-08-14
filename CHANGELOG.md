# Changelog

All notable changes to Iris Vault will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `.scripts/make-distributable.sh` builds the sendable `iris-vault.zip` from the repository. It refuses to build when the clone is not at published HEAD, scans every build for private data and abandoned it if anything is found, and checks the finished zip for the files onboarding depends on.
- `pnpm docs:check` (`.scripts/docs-check.mjs`) fails when an onboarding document tells the reader to run a command as a first step, when a door stops showing the five steps or pointing at `START HERE.md`, or when the retired setup wizard is referenced anywhere outside the changelog.

### Changed
- The README leads with the five steps: download, unzip, open in the Claude app, say hi. Clone and `install.sh` moved into a section for people who use a terminal.
- `00_Inbox/Welcome.md` no longer contradicts `CLAUDE.md` by telling the reader to run a setup command.
- `install.sh` is optional extras, reports which steps failed, and exits non-zero instead of printing "Setup Complete" over a broken install. It also removes an `origin` pointing at the public starter-kit repository, so a personal vault has no push target somebody else owns.

### Removed
- `IRIS-BOOTSTRAP.md` and `/init-bootstrap`. Setup is the FIRST RUN conversation in `CLAUDE.md`.

## [0.1.0] - 2026-03-05

### Added
- Initial release of Iris Vault
- Interactive setup wizard via `/init-bootstrap`
  - Public profile research during setup
  - Existing vault import with OLD_VAULT preservation
  - iCloud vault setup option (macOS)
  - Knowledge import from ChatGPT/Gemini chat exports
  - Feature opt-ins (daily journal, weekly review, auto-sync, council)
  - Quick-start trigger phrase configuration
- Council command (`/council`) for multi-perspective reasoning
  - Independent agents with genuine worldviews (not performative debate)
  - Configurable perspectives (default: Pragmatist, Contrarian, Humanist)
  - Vault-aware context loading
  - Synthesis agent for cross-perspective insights
- Self-maintaining CLAUDE.md system
  - Proactive context loading instructions
  - Auto-maintained reference paths table
  - Living document that grows with the vault
- Customizable daily review command
- Two-phase weekly synthesis (autonomous retrospective + interactive prospective)
- Inbox processor with LLM chat export support
- PARA method folder structure with Iris additions (Council/, Daily Journal/, Weekly Reviews/)
- Auto-sync hooks (opt-in, local commits only)
- Gemini Vision MCP server for image/PDF/video analysis (optional)
- Firecrawl web scraping integration (optional)
- Helper scripts for vault management
- Pre-configured commands: thinking-partner, research-assistant, add-frontmatter, create-command, de-ai-ify

### Credits
- Built on ideas from [Claudesidian](https://github.com/heyitsnoah/claudesidian) by Noah Brier and [Alephic](https://alephic.com)

[Unreleased]: https://github.com/mikedouzinas/iris-vault/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/mikedouzinas/iris-vault/releases/tag/v0.1.0
