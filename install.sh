#!/bin/bash
#
# Optional extras for Iris Vault.
#
# You do not need this script. The vault works with nothing installed: open the folder in the
# Claude app, say hi, and Iris sets itself up as a conversation. See START HERE.md.
#
# This script is for the extras: the Gemini Vision MCP server (image, PDF, and video analysis),
# the optional command-line tools, and the git setup if you want version history.
#
# It reports failures. It does not print "complete" when a step did not work.

echo "Iris Vault: optional extras"
echo "==========================="
echo ""
echo "Nothing here is required. If you skip this entirely, the vault still works."
echo ""

FAILURES=()

check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "  $1 is not installed"
        return 1
    else
        echo "  $1 is installed"
        return 0
    fi
}

echo "Checking required tools..."
echo ""

check_command "git"
GIT_OK=$?

check_command "node"
NODE_OK=$?

check_command "pnpm"
PNPM_OK=$?

echo ""
echo "Checking optional tools..."
check_command "yt-dlp" || echo "   Install with: brew install yt-dlp (for YouTube transcripts)"
check_command "jq" || echo "   Install with: brew install jq (for JSON processing)"
check_command "rg" || echo "   Install with: brew install ripgrep (for better search)"

echo ""

# ---------------------------------------------------------------------------
# Dependencies. Every step reports what actually happened.
# ---------------------------------------------------------------------------

if [ $NODE_OK -ne 0 ]; then
    echo "Skipping dependencies: node is not installed."
    echo "   Install Node from https://nodejs.org and run this script again."
    echo "   Only the Gemini Vision server needs it. Everything else works without it."
    FAILURES+=("node is not installed, so dependencies were not installed")
else
    if [ $PNPM_OK -ne 0 ]; then
        echo "Installing pnpm..."
        if npm install -g pnpm; then
            echo "pnpm installed"
            PNPM_OK=0
        else
            echo "FAILED: could not install pnpm."
            echo "   Try: npm install -g pnpm"
            echo "   Or install it from https://pnpm.io/installation"
            FAILURES+=("pnpm could not be installed")
        fi
    fi

    if [ $PNPM_OK -eq 0 ]; then
        echo "Installing dependencies..."
        if pnpm install; then
            echo "Dependencies installed"
        else
            echo "FAILED: pnpm install did not complete."
            FAILURES+=("pnpm install failed")
        fi
    else
        echo "Skipping dependencies: pnpm is not available."
        FAILURES+=("dependencies were not installed")
    fi
fi

echo ""
echo "Creating folder structure..."
if mkdir -p 00_Inbox 01_Projects 02_Areas 03_Resources 04_Archive 05_Attachments/Organized "06_Metadata/Daily Journal" "06_Metadata/Weekly Reviews" "06_Metadata/Council" "06_Metadata/Reference" "06_Metadata/Templates"; then
    echo "Folders created"
else
    echo "FAILED: could not create the folder structure."
    FAILURES+=("folder structure could not be created")
fi

# ---------------------------------------------------------------------------
# Git. A clone leaves origin pointed at the public starter-kit repo, and a personal
# vault must never have a push target somebody else owns.
# ---------------------------------------------------------------------------

if [ $GIT_OK -eq 0 ]; then
    if [ ! -d ".git" ]; then
        echo ""
        echo "Initializing git repository..."
        if git init && git add . && git commit -q -m "Initial vault setup"; then
            echo "Git repository initialized"
        else
            echo "FAILED: git setup did not complete. Your files are fine, there is just no history yet."
            FAILURES+=("git repository was not initialized")
        fi
    else
        ORIGIN="$(git remote get-url origin 2>/dev/null)"
        case "$ORIGIN" in
            *mikedouzinas/iris-vault*)
                echo ""
                echo "This folder is still connected to the public starter-kit repository."
                echo "Your notes are private and should not have a push target somebody else owns."
                if git remote remove origin; then
                    echo "Removed 'origin'. Your history stays, there is just nowhere to push it by accident."
                else
                    echo "FAILED: could not remove 'origin'. Remove it by hand: git remote remove origin"
                    FAILURES+=("origin still points at the public starter-kit repository")
                fi
                ;;
        esac
    fi
fi

echo ""
echo "Gemini Vision Setup (Optional)"
echo "==============================="
echo ""
echo "To enable image and document analysis:"
echo "1. Get your free API key from: https://aistudio.google.com/apikey"
echo "2. Add to your shell profile (~/.zshrc or ~/.bashrc):"
echo ""
echo "   export GEMINI_API_KEY='your-key-here'"
echo ""
echo "3. Reload your shell: source ~/.zshrc"
echo "4. Test with: pnpm test-gemini"
echo ""

if [ -d "/Applications/Obsidian.app" ] || [ -d "$HOME/.local/share/applications/obsidian.desktop" ]; then
    echo "Obsidian detected"
    echo "   Open this folder as a vault in Obsidian"
else
    echo "Obsidian is optional. If you want a visual interface: https://obsidian.md"
fi

echo ""

if [ ${#FAILURES[@]} -ne 0 ]; then
    echo "Extras did not finish"
    echo "====================="
    echo ""
    for failure in "${FAILURES[@]}"; do
        echo "  - $failure"
    done
    echo ""
    echo "Your vault still works. None of the above is needed to use it:"
    echo "open this folder in the Claude app and say hi."
    exit 1
fi

echo "Extras installed"
echo "================"
echo ""
echo "To use the vault: open this folder in the Claude app and say hi."
echo "In a terminal: run 'claude' in this folder and say hi."
echo ""
