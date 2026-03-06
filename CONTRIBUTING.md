# Contributing to Apollo Vault

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Development Setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/apollo-vault.git`
3. Install dependencies: `pnpm install`
4. Create a feature branch: `git checkout -b feature/your-feature-name`

## Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes
- `refactor:` Code refactoring
- `test:` Test additions or changes
- `chore:` Maintenance tasks

## Versioning

We use [Semantic Versioning](https://semver.org/):
- MAJOR (1.0.0): Breaking changes
- MINOR (0.1.0): New features (backward compatible)
- PATCH (0.0.1): Bug fixes (backward compatible)

## Pull Request Process

1. Update CHANGELOG.md with your changes under "Unreleased"
2. Update documentation if needed
3. Ensure all scripts still work
4. Submit PR with clear description

## Changelog Updates

Add your changes to CHANGELOG.md under "Unreleased":

```markdown
## [Unreleased]

### Added
- Your new feature here

### Fixed
- Your bug fix here
```

Categories: Added, Changed, Deprecated, Removed, Fixed, Security

## Testing Changes

```bash
# Fresh clone test
git clone your-fork test-vault
cd test-vault
pnpm install
claude  # Then run /init-bootstrap
```

## Questions?

Open an issue for discussion before making large changes.
