#!/bin/bash
#
# Publish SETUP.md to the portfolio so it is served at mikeveson.com/setup.
#
# SETUP.md is the instruction sheet Claude fetches when someone pastes the one-line setup
# prompt. It is copied from this repository, never hand-edited in the portfolio, so the
# served copy cannot drift from the vault it sets up. That is the same rule the zip follows.
#
#   ./.scripts/publish-setup.sh              # copy SETUP.md into the portfolio
#   ./.scripts/publish-setup.sh --check      # fail if the served copy is stale
#
# --check runs in pnpm vault:check, so a change to SETUP.md that was never published
# fails loudly instead of silently serving the old instructions.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_ROOT/SETUP.md"
PORTFOLIO="${IRIS_PORTFOLIO_DIR:-$HOME/Downloads/Dev/mikedouz-portfolio}"
DEST="$PORTFOLIO/public/setup.md"

CHECK=0
[ "${1:-}" = "--check" ] && CHECK=1

if [ ! -f "$SRC" ]; then
  echo "publish-setup: SETUP.md is missing from the repository root." >&2
  exit 1
fi

# The prompt people paste names this URL. If the file stops being reachable there, the
# prompt silently sets up nothing, so the destination is checked rather than assumed.
if [ ! -d "$PORTFOLIO/public" ]; then
  echo "publish-setup: portfolio public/ not found at $PORTFOLIO." >&2
  echo "               set IRIS_PORTFOLIO_DIR if it lives somewhere else." >&2
  exit 1
fi

if [ "$CHECK" = "1" ]; then
  if [ ! -f "$DEST" ]; then
    echo "publish-setup FAILED  mikeveson.com/setup has never been published." >&2
    echo "                      run ./.scripts/publish-setup.sh" >&2
    exit 1
  fi
  if ! diff -q "$SRC" "$DEST" >/dev/null; then
    echo "publish-setup FAILED  SETUP.md has changed since it was last published." >&2
    echo "                      the served copy at mikeveson.com/setup is stale." >&2
    echo "                      run ./.scripts/publish-setup.sh" >&2
    exit 1
  fi
  echo "publish-setup  served copy matches SETUP.md."
  exit 0
fi

cp "$SRC" "$DEST"
echo "publish-setup  SETUP.md -> $DEST"

# The copy lands in whatever branch the portfolio happens to have checked out, which is
# usually not the branch that serves the site. Say which one, so the file is not left
# stranded on unrelated work.
BRANCH="$(git -C "$PORTFOLIO" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
echo "               written on portfolio branch: $BRANCH"
if [ "$BRANCH" != "main" ]; then
  echo "               this is not main, so it will not deploy until that branch merges."
fi
echo "               commit and deploy the portfolio to serve it at mikeveson.com/setup"
