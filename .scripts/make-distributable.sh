#!/bin/bash
#
# Build the sendable vault: iris-vault.zip
#
# The zip is what a non-technical person downloads, unzips, and opens in the Claude app.
# It is generated from the repository, never hand-assembled, so it cannot drift from what
# is published.
#
#   ./.scripts/make-distributable.sh                  # build from published main (the normal path)
#   ./.scripts/make-distributable.sh --from-local     # build from this repo's HEAD (pre-merge)
#   ./.scripts/make-distributable.sh --out /path/iris-vault.zip
#
# Two things make this safe to run unattended:
#   1. The default path clones the published remote and refuses to build if that clone is not
#      at the current published HEAD.
#   2. Every build is scanned for private markers and for the files the recipient needs.
#      A failed scan aborts the build. There is no flag to skip it.

set -euo pipefail

REMOTE="https://github.com/mikedouzinas/iris-vault.git"
BRANCH="main"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$REPO_ROOT/dist/iris-vault.zip"
FROM_LOCAL=0

while [ $# -gt 0 ]; do
    case "$1" in
        --from-local) FROM_LOCAL=1; shift ;;
        --out) OUT="$2"; shift 2 ;;
        -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
        *) echo "Unknown option: $1" >&2; exit 2 ;;
    esac
done

for tool in git zip unzip node; do
    command -v "$tool" >/dev/null 2>&1 || { echo "FAIL: $tool is required and is not installed." >&2; exit 1; }
done

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
STAGE="$WORK/iris-vault"

if [ "$FROM_LOCAL" -eq 1 ]; then
    echo "Source: local HEAD of $REPO_ROOT"
    echo "        This is a pre-merge build. It is NOT what is published at $REMOTE."
    if ! git -C "$REPO_ROOT" diff --quiet HEAD -- || [ -n "$(git -C "$REPO_ROOT" ls-files --others --exclude-standard)" ]; then
        echo "FAIL: working tree is dirty. Commit first, so the zip matches a commit you can point at." >&2
        exit 1
    fi
    mkdir -p "$STAGE"
    git -C "$REPO_ROOT" archive HEAD | tar -x -C "$STAGE"
    SOURCE_REF="$(git -C "$REPO_ROOT" rev-parse HEAD) (local, $(git -C "$REPO_ROOT" branch --show-current))"
else
    echo "Source: $REMOTE ($BRANCH)"
    PUBLISHED="$(git ls-remote "$REMOTE" "refs/heads/$BRANCH" | cut -f1)"
    [ -n "$PUBLISHED" ] || { echo "FAIL: could not read $BRANCH from $REMOTE." >&2; exit 1; }
    git clone --quiet --depth 1 --branch "$BRANCH" "$REMOTE" "$STAGE"
    CLONED="$(git -C "$STAGE" rev-parse HEAD)"
    if [ "$CLONED" != "$PUBLISHED" ]; then
        echo "FAIL: clone is at $CLONED, published $BRANCH is at $PUBLISHED." >&2
        exit 1
    fi
    SOURCE_REF="$CLONED (published $BRANCH)"
fi

# Strip everything the recipient does not need and everything that identifies a machine.
rm -rf "$STAGE/.git" "$STAGE/node_modules" "$STAGE/.github" "$STAGE/dist"
rm -f "$STAGE/.claude/settings.local.json"
find "$STAGE" -name '.DS_Store' -delete
find "$STAGE" -name '__MACOSX' -prune -exec rm -rf {} + 2>/dev/null || true

# Maintainer-only files. The recipient is somebody's mother opening a folder, not a contributor,
# and this script in particular carries the personal-address markers used by the scan below.
# Removing it here is also what lets that scan run with nothing excluded from it.
MAINTAINER_ONLY=(".scripts/make-distributable.sh" "MAINTAINERS.md" "CONTRIBUTING.md")
for m in "${MAINTAINER_ONLY[@]}"; do
    rm -f "$STAGE/$m"
done

# A stripped file that package.json still calls is a broken command in the recipient's copy,
# so the scripts that referenced them go too, and the check below proves none are left dangling.
node -e '
const fs = require("fs");
const p = process.argv[1];
const pkg = JSON.parse(fs.readFileSync(p, "utf8"));
delete pkg.scripts.dist;
fs.writeFileSync(p, JSON.stringify(pkg, null, 2) + "\n");
' "$STAGE/package.json"

# ---------------------------------------------------------------------------
# Leak scan. A private file in this zip is the worst outcome this script can have,
# so it is checked here rather than trusted.
# ---------------------------------------------------------------------------
echo ""
echo "Scanning for private data..."

FAILED=0

# Paths that only ever exist in a real person's vault, never in the starter kit.
for private_path in \
    "06_Metadata/Daily Journal" \
    "06_Metadata/Weekly Reviews" \
    "02_Areas/Relationships" \
    "02_Areas/Self-Knowledge" \
    "02_Areas/Health & Energy" \
    "05_Process" \
    "03_Resources/Wiki" \
    "01_Projects/Project Olympus" \
    ".env" ".env.local" ".mcp.json"
do
    if [ -e "$STAGE/$private_path" ]; then
        echo "  LEAK: $private_path is in the build" >&2
        FAILED=1
    fi
done

# Any markdown file in a content folder is content, and the starter kit ships only READMEs
# and templates. Anything else means somebody's notes came along.
UNEXPECTED="$(find "$STAGE/00_Inbox" "$STAGE/01_Projects" "$STAGE/02_Areas" "$STAGE/03_Resources" \
    "$STAGE/04_Archive" "$STAGE/05_Attachments" "$STAGE/06_Metadata" -type f \
    ! -name 'README.md' ! -name '.gitkeep' ! -name 'Welcome.md' \
    ! -path '*06_Metadata/Templates/*' ! -path '*06_Metadata/Reference/*' 2>/dev/null || true)"
if [ -n "$UNEXPECTED" ]; then
    echo "  LEAK: unexpected content files in the build:" >&2
    echo "$UNEXPECTED" | sed "s|$STAGE|  |" >&2
    FAILED=1
fi

# Personal addresses. Nothing is excluded from this scan: the only file that carried these
# markers was this script, and it was removed from the stage above.
for marker in "sideromv" "sideroman" "mv57@rice.edu" "@douzinas.com"; do
    if grep -rqiF "$marker" "$STAGE" 2>/dev/null; then
        echo "  LEAK: '$marker' appears in the build" >&2
        grep -rniF "$marker" "$STAGE" 2>/dev/null | sed "s|$STAGE|  |" | head -5 >&2
        FAILED=1
    fi
done

# Live credentials. These patterns match a real key, not the word or a placeholder.
for pattern in "sk-ant-[A-Za-z0-9_-]{12}" "ghp_[A-Za-z0-9]{12}" "AIza[0-9A-Za-z_-]{20}" "eyJ[A-Za-z0-9_-]{30}"; do
    if grep -rqE "$pattern" "$STAGE" 2>/dev/null; then
        echo "  LEAK: a credential matching /$pattern/ is in the build" >&2
        grep -rnE "$pattern" "$STAGE" 2>/dev/null | cut -c1-120 | sed "s|$STAGE|  |" | head -5 >&2
        FAILED=1
    fi
done

if [ "$FAILED" -ne 0 ]; then
    echo "" >&2
    echo "ABORTED. Nothing was written." >&2
    exit 1
fi
echo "  clean"

# ---------------------------------------------------------------------------
# The recipient's first five minutes depend on these existing. Check, do not assume.
# ---------------------------------------------------------------------------
echo ""
echo "Checking the files onboarding depends on..."
for required in "CLAUDE.md" "START HERE.md" "FIRST_RUN" ".claude/settings.json"; do
    if [ ! -e "$STAGE/$required" ]; then
        echo "  MISSING: $required" >&2
        FAILED=1
    fi
done
if ! grep -q "FIRST RUN" "$STAGE/CLAUDE.md"; then
    echo "  MISSING: CLAUDE.md has no FIRST RUN block, so the vault will not introduce itself." >&2
    FAILED=1
fi

# Every .scripts/ path that package.json still calls has to be in the stage. This is what stops
# a file being stripped above while a command that runs it survives.
DANGLING="$(node -e '
const fs = require("fs");
const [pkgPath, stage] = process.argv.slice(1);
const scripts = JSON.parse(fs.readFileSync(pkgPath, "utf8")).scripts || {};
const missing = [];
for (const [name, cmd] of Object.entries(scripts)) {
  for (const m of String(cmd).matchAll(/\.scripts\/[A-Za-z0-9._-]+/g)) {
    if (!fs.existsSync(stage + "/" + m[0])) missing.push(name + " -> " + m[0]);
  }
}
console.log(missing.join("\n"));
' "$STAGE/package.json" "$STAGE")"
if [ -n "$DANGLING" ]; then
    echo "  DANGLING: package.json calls a script that is not in the build:" >&2
    echo "$DANGLING" | sed 's|^|    |' >&2
    FAILED=1
fi
if [ "$FAILED" -ne 0 ]; then
    echo "" >&2
    echo "ABORTED. Nothing was written." >&2
    exit 1
fi
echo "  present"

mkdir -p "$(dirname "$OUT")"
rm -f "$OUT"
( cd "$WORK" && zip -q -r -X "$OUT" "iris-vault" )

# Read the finished artifact back rather than trusting what went in.
# The manifest is captured before it is searched: piping into `grep -q` under `pipefail`
# reports a failure when grep exits early and unzip takes a SIGPIPE.
MANIFEST="$(unzip -l "$OUT")"
for entry in "iris-vault/CLAUDE.md" "iris-vault/START HERE.md" "iris-vault/FIRST_RUN" "iris-vault/.claude/settings.json"; do
    if ! grep -qF "$entry" <<< "$MANIFEST"; then
        echo "FAIL: $entry is not in the finished zip." >&2
        rm -f "$OUT"
        exit 1
    fi
done
for forbidden in "iris-vault/.git/" "node_modules/" "settings.local.json"; do
    if grep -qF "$forbidden" <<< "$MANIFEST"; then
        echo "FAIL: $forbidden made it into the finished zip." >&2
        rm -f "$OUT"
        exit 1
    fi
done

echo ""
echo "Built: $OUT"
echo "From:  $SOURCE_REF"
echo "Size:  $(du -h "$OUT" | cut -f1)"
echo "Files: $(tail -1 <<< "$MANIFEST" | awk '{print $2}')"
