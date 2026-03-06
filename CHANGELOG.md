# Changelog

All notable changes to Apollo Vault will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-03-05

### Added
- Initial release of Apollo Vault
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
- PARA method folder structure with Apollo additions (Council/, Daily Journal/, Weekly Reviews/)
- Auto-sync hooks (opt-in, local commits only)
- Gemini Vision MCP server for image/PDF/video analysis (optional)
- Firecrawl web scraping integration (optional)
- Helper scripts for vault management
- Pre-configured commands: thinking-partner, research-assistant, add-frontmatter, create-command, de-ai-ify

### Credits
- Built on ideas from [Claudesidian](https://github.com/heyitsnoah/claudesidian) by Noah Brier and [Alephic](https://alephic.com)

[Unreleased]: https://github.com/mikedouzinas/apollo-vault/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/mikedouzinas/apollo-vault/releases/tag/v0.1.0
