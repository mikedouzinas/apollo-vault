#!/bin/bash

echo "Apollo Vault Setup"
echo "=================="
echo ""

# Check for required tools
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

if [ $PNPM_OK -ne 0 ]; then
    echo "Installing pnpm..."
    npm install -g pnpm
    echo "pnpm installed"
fi

echo "Installing dependencies..."
pnpm install

echo ""
echo "Creating folder structure..."
mkdir -p 00_Inbox 01_Projects 02_Areas 03_Resources 04_Archive 05_Attachments/Organized "06_Metadata/Daily Journal" "06_Metadata/Weekly Reviews" "06_Metadata/Council" "06_Metadata/Reference" "06_Metadata/Templates"
echo "Folders created"

if [ $GIT_OK -eq 0 ]; then
    if [ ! -d ".git" ]; then
        echo ""
        echo "Initializing git repository..."
        git init
        git add .
        git commit -m "Initial vault setup"
        echo "Git repository initialized"
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
    echo "Download Obsidian from: https://obsidian.md"
    echo "   Then open this folder as a vault"
fi

echo ""
echo "Setup Complete!"
echo "==============="
echo ""
echo "Next steps:"
echo "1. Start Claude Code in this directory: claude"
echo "2. Run the setup wizard: /init-bootstrap"
echo "3. Or try: /thinking-partner"
echo ""
echo "Your vault is ready."
