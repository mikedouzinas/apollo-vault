---
description: Intelligently upgrade Apollo Vault with new features while preserving your customizations
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

# Upgrade Apollo Vault

Upgrade your Apollo Vault installation with the latest features while preserving your customizations.

## Process

### 1. Check Current Version

```bash
cat package.json | grep version
```

### 2. Fetch Latest

```bash
git fetch origin main 2>/dev/null || echo "No remote configured"
```

### 3. Compare Changes

If remote is available:
```bash
git diff HEAD..origin/main --stat
```

### 4. Smart Merge

For each changed file:
- **Config files** (vault-config.json, CLAUDE.md): Preserve user customizations, merge new features
- **Commands**: Update to latest version, preserve any user modifications
- **Scripts**: Update to latest version
- **Templates**: Add new templates, don't overwrite modified ones

### 5. Post-Upgrade

- Run `pnpm install` to update dependencies
- Run `pnpm vault:stats` to verify
- Show summary of what changed

## Important

- Your CLAUDE.md customizations are always preserved
- Your vault-config.json preferences are always preserved
- New commands are added alongside existing ones
- Modified commands are flagged for manual review
