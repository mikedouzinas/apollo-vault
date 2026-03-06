---
name: release
description: Automatically bump version, update changelog, commit, tag, and push a new release based on recent changes
allowed-tools: [Read, Write, Edit, MultiEdit, Bash, Grep]
argument-hint: "(optional) 'major', 'minor', 'patch', or leave blank for auto-detection"
---

# Release Command

Automates the entire release process: analyzes recent commits to determine version bump type, updates version in package.json, moves unreleased changelog entries to the new version, commits everything, creates a git tag, and pushes to GitHub.

## Task

1. Analyze recent commits since last tag to determine version bump type
2. Update version in package.json
3. Move "Unreleased" entries in CHANGELOG.md to the new version section
4. Commit the changes
5. Create an annotated git tag
6. Push commits and tags to GitHub

## Process

1. **Check Prerequisites**
   - Ensure on main/master branch
   - Check for uncommitted changes
   - Verify CHANGELOG.md and package.json exist
   - Get current version from package.json

2. **Determine Version Bump**
   - If argument provided (major/minor/patch), use that
   - Otherwise, analyze commits since last tag:
     - Look for "BREAKING CHANGE" or "!" = major bump
     - Look for "feat:" = minor bump
     - Look for "fix:", "docs:", "chore:" = patch bump
   - Calculate new version number

3. **Update Files**
   - Update version in package.json
   - Move "Unreleased" section in CHANGELOG.md to new version section
   - Add comparison links for the new version
   - Create new empty "Unreleased" section

4. **Git Operations**
   - Stage changes: `git add package.json CHANGELOG.md`
   - Commit: `git commit -m "chore: release v{version}"`
   - Create annotated tag: `git tag -a v{version} -m "Release v{version}"`
   - Push commits: `git push`
   - Push tags: `git push --tags`

5. **Provide Next Steps**
   - Show link to create GitHub release
   - Remind to add release notes from changelog

## Version Bump Rules

### Semantic Versioning (MAJOR.MINOR.PATCH)

**MAJOR** (1.0.0 → 2.0.0):
- Breaking changes
- Commits with "BREAKING CHANGE" in body
- Commits with "!" after type (e.g., "feat!:")

**MINOR** (1.0.0 → 1.1.0):
- New features (backward compatible)
- Commits starting with "feat:"

**PATCH** (1.0.0 → 1.0.1):
- Bug fixes and minor changes
- Commits with "fix:", "docs:", "style:", "refactor:", "test:", "chore:"

## Example Usage

```bash
# Auto-detect version bump from commits
claude run release

# Force specific version bump
claude run release patch
claude run release minor
claude run release major

# Example output:
# 📦 Current version: 0.1.0
# 🔍 Analyzing commits since last release...
#
# Found commits:
# - feat: add video support to Gemini Vision
# - docs: update README with setup instructions
# - fix: correct attachment link handling
#
# ✨ Detected version bump: MINOR (new features added)
# 📝 New version: 0.2.0
#
# ✅ Updated package.json
# ✅ Updated CHANGELOG.md
# ✅ Committed changes
# ✅ Created tag v0.2.0
# ✅ Pushed to GitHub
#
# 🎉 Release v0.2.0 complete!
#
# Next steps:
# 1. Go to https://github.com/user/repo/releases/new?tag=v0.2.0
# 2. Add release notes from CHANGELOG.md
# 3. Publish the release
```

## Error Handling

- If not on main branch: "Please switch to main branch first"
- If uncommitted changes: "Please commit or stash changes first"
- If no changes since last release: "No changes to release"
- If version already exists: "Version X.X.X already exists"

## Safety Features

- Dry run mode: Show what would happen without making changes
- Confirmation prompt before pushing
- Validation of version format
- Check for existing tags before creating