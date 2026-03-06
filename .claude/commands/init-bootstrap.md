---
name: init-bootstrap
description: Interactive setup wizard that configures your vault, learns about you, and generates a personalized CLAUDE.md
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep, Agent, WebSearch, WebFetch]
argument-hint: "(optional) path to existing vault or 'new' for fresh setup"
---

# Initialize Apollo Vault

This command walks you through configuring your vault in a real conversation, not a form. It learns about you, imports your existing knowledge, and generates a personalized CLAUDE.md that makes Claude intelligent about your vault.

## Process

### Phase 1: Environment Setup

1. **Get current date** for timestamps:
   ```bash
   date +"%B %d, %Y"
   ```

2. **Check current folder name** and ask if they want to rename it:
   - If yes, guide through renaming (handle parent directory move)

3. **Install dependencies:**
   - Try `pnpm install` first
   - Fall back to `npm install` if pnpm not available

4. **Check git status:**
   - If no .git folder: Initialize git repository
   - If has remote origin pointing to apollo-vault repo: Ask about development work
     - Personal vault: Remove origin and .github folder
     - Contributing: Keep origin and workflows intact
   - If clean local repo: Ready to go

5. Don't create folders yet — wait until after asking about organization method

### Phase 2: Vault Discovery

6. **Search for existing Obsidian vaults** (.obsidian folder):
   Check these paths with appropriate depth limits:
   - `~/Documents` (maxdepth 3)
   - `~/Desktop` (maxdepth 3)
   - `~/Library/Mobile Documents/iCloud~md~obsidian/Documents` (maxdepth 5, macOS only)
   - Home directory `~/` (maxdepth 2)
   - Current directory parent (maxdepth 2)

7. **Offer iCloud setup** (macOS only):
   - "Would you like your vault in iCloud so you can access it from any Mac with Claude Code?"
   - If yes and not already in iCloud: guide through moving the vault
   - If user provides a custom path, validate it exists

8. **If existing vault found:**
   - Ask: "Found Obsidian vault at [path]. Is this the vault you want to import?"
   - If confirmed:
     - Count files: `find [path] -type f -name "*.md" | wc -l`
     - Show vault size: `du -sh [path]`
     - Analyze structure: `tree -L 3 -d [path]`
     - Sample 10-15 random notes to understand content types
     - Detect organization method (PARA, Zettelkasten, custom)
   - Import: `mkdir OLD_VAULT && cp -r [vault-path]/* ./OLD_VAULT/`
   - Copy .obsidian config: `cp -r [vault-path]/.obsidian ./`
   - Skip: `.git/`, `.claude/`

9. **If no existing vault or starting fresh:** proceed to personalization

### Phase 3: Personalization

10. **"What's your name?"** (and preferred name if different)

11. **"Would you like me to research your public work to better understand your context?"**
    - If yes: Use WebSearch to find information about them
    - ALWAYS show findings and ask "Is this correct?"
    - If multiple people found, list them numbered for selection
    - If wrong person, offer to search again or skip
    - Save: work, writing style, areas of expertise, interests

12. **Organization method:**
    - "Do you follow the PARA method or have a different organization system?"
    - If PARA: create standard folders (00_Inbox through 06_Metadata)
    - If custom: ask about their structure and create it

13. **If PARA, ask specific setup questions:**
    - "What active projects are you working on?" (Create folders in 01_Projects)
    - "What areas of responsibility do you maintain?" (Create in 02_Areas)
    - "What topics do you research frequently?" (Set up in 03_Resources)
    - For each project: create subfolders (Research/, Drafts/, Daily Progress/)

14. **Communication style:**
    - "How do you want Claude to communicate with you?"
    - Options:
      a. **Direct and challenging** - Call out inconsistencies, push back, take positions
      b. **Warm and supportive** - Encouraging, gentle challenges, positive framing
      c. **Neutral and professional** - Balanced, measured, objective
    - Store choice for CLAUDE.md generation

15. **Primary use cases:**
    - "What do you use your vault for primarily?"
    - Options (select multiple): Research / Writing / Project management / Personal development / Knowledge base / Creative work / Academic / Professional
    - This informs which features to emphasize

16. **Writing style preferences:**
    - Check .obsidian/community-plugins.json for plugin insights
    - Analyze existing files to detect naming convention automatically
    - Ask about any specific style preferences
    - "Do you have any specific workflows or patterns you want Claude to follow?"

### Phase 3.5: Knowledge Import

17. **"Do you have files you'd like Apollo to learn from?"**
    - "This could be exported chats from ChatGPT or Gemini, existing notes, project docs, anything about you or your work."
    - "Drop them into 00_Inbox/ and tell me when you're ready."
    - "Or type 'skip' to continue without importing."

18. **If files are dropped:**
    - Run `/inbox setup` logic:
      - Scan 00_Inbox/ for new files
      - For each file:
        - Detect type (chat export JSON, conversation text, document, notes)
        - Extract key insights, decisions, preferences, recurring themes
        - Identify project context, expertise areas, interests
      - Report findings: "Here's what I learned about you from these files:"
      - Use findings to auto-suggest additional projects, areas, vault structure
      - File processed content into appropriate vault locations
      - Ask for confirmation before moving things

### Phase 4: Feature Configuration

19. **Daily Journal:**
    - "Would you like Claude to maintain a daily journal? It captures key insights from your conversations automatically."
    - If yes:
      - Create `06_Metadata/Daily Journal/` (already exists in structure)
      - Add journal instructions to CLAUDE.md
      - Store `dailyJournal.enabled: true` in vault-config.json

20. **Weekly Review:**
    - "Would you like a weekly review ritual? It looks at patterns across the week and helps you plan the next one."
    - If yes:
      - "What day works best?" (default: Sunday)
      - "What do you want the review to focus on?" Options:
        a. Project progress and blockers
        b. Energy and productivity patterns
        c. Personal growth and patterns
        d. All of the above
      - Store preferences in vault-config.json

21. **Daily Review:**
    - "Would you like end-of-day check-ins? Quick 5-10 minute reflections."
    - If yes:
      - "What should the review focus on?" Offer to customize the 3 core questions or use defaults
      - Store in vault-config.json

22. **Auto-sync hooks:**
    - "Would you like the vault to auto-commit changes whenever Claude edits a file? This keeps a history of every change. (Local commits only, nothing is pushed anywhere.)"
    - If yes: add Write and Edit hooks to `.claude/settings.json`:
      ```json
      {
        "matcher": "Write",
        "hooks": [{"type": "command", "command": "git add -A && git commit -m 'Auto-sync: File written' 2>/dev/null || true"}]
      },
      {
        "matcher": "Edit",
        "hooks": [{"type": "command", "command": "git add -A && git commit -m 'Auto-sync: File edited' 2>/dev/null || true"}]
      }
      ```

23. **Council perspectives:**
    - "The `/council` command lets you think through ideas from multiple angles. Three agents with different worldviews each analyze your question independently, then a synthesis pulls out the real insight."
    - "Default perspectives are Pragmatist, Contrarian, and Humanist. Would you like to customize these?"
    - If yes: walk through creating 2-4 custom perspectives
      - For each: "What worldview should this perspective have? Describe how they think."
      - Generate a system prompt from their description
    - Store in vault-config.json under `council.perspectives`

24. **Quick-start triggers:**
    - "You can set up shortcut phrases that load specific context. For example, saying 'Let's work' could load your active projects and show what needs attention."
    - "Want to set some up? (You can always add more later by editing CLAUDE.md)"
    - If yes: walk through 2-3 trigger phrases
      - For each: "What phrase?" and "What should it do?"
    - Store for CLAUDE.md generation

### Phase 5: Tools Setup

25. **Gemini Vision:**
    - "Gemini Vision is included for analyzing images, PDFs, and videos. Would you like to activate it? You just need a free API key from Google."
    - If yes:
      - Guide to https://aistudio.google.com/apikey
      - Help add to shell profile (~/.zshrc or ~/.bashrc)
      - Run `claude mcp add --scope project gemini-vision node .claude/mcp-servers/gemini-vision.mjs`
      - Test the connection
    - If later: "Run `/setup-gemini` anytime to set it up."

26. **Firecrawl:**
    - "Firecrawl lets you save any web page to your vault as searchable markdown. Would you like to set it up?"
    - If yes:
      - Guide to https://firecrawl.dev for API key
      - Configure scripts in .scripts/
    - If later: "The scripts are ready in .scripts/ whenever you get an API key."

### Phase 6: Experimental

27. **NanoClaw (optional, clearly marked):**
    - "There's an experimental feature called NanoClaw that runs an always-on background agent accessible via Telegram. It can check your calendar, send messages, and work on tasks while you're away from the computer."
    - "**Important:** This requires Docker, is currently unstable, and needs technical setup. It's best suited for developers comfortable with containerized services."
    - "Want to learn more? (yes/no)"
    - If yes: provide link to NanoClaw docs, explain requirements, don't attempt setup in this wizard
    - If no: skip entirely

### Phase 7: Generate Everything

28. **Save preferences to `.claude/vault-config.json`:**

```json
{
  "user": {
    "name": "[full name]",
    "preferredName": "[preferred name]",
    "background": {
      "education": [],
      "companies": [],
      "roles": [],
      "expertise": [],
      "interests": []
    },
    "profileSources": [],
    "customContext": "[summary from research + imports]",
    "publicProfile": true/false,
    "writingStyle": {
      "tone": "[from preferences]",
      "approach": "[from preferences]",
      "preferences": []
    },
    "communicationStyle": "direct/warm/neutral"
  },
  "vaultPath": "[path]",
  "fileNamingPattern": "[detected or chosen]",
  "organizationMethod": "PARA",
  "primaryUses": [],
  "tools": {
    "geminiVision": true/false,
    "firecrawl": true/false
  },
  "projects": [],
  "areas": [],
  "resources": [],
  "dailyJournal": {
    "enabled": true/false,
    "location": "06_Metadata/Daily Journal/"
  },
  "dailyReview": {
    "enabled": true/false,
    "questions": []
  },
  "weeklyReview": {
    "enabled": true/false,
    "day": "",
    "focusAreas": []
  },
  "autoSync": {
    "enabled": true/false
  },
  "council": {
    "perspectives": [
      {
        "name": "Pragmatist",
        "prompt": "You value what actually works. Theory is only useful if it survives contact with reality. You care about implementation, second-order effects, and whether something will hold up under pressure."
      },
      {
        "name": "Contrarian",
        "prompt": "You notice what everyone else misses. You're drawn to the overlooked angle, the assumption nobody questioned. You build your own case from first principles."
      },
      {
        "name": "Humanist",
        "prompt": "You care about people. How does this affect relationships, wellbeing, and the lived experience of the humans involved? You think in terms of values, meaning, and long-term flourishing."
      }
    ]
  },
  "triggers": {},
  "importedAt": "[date]",
  "lastUpdated": "[date]"
}
```

29. **Generate personalized CLAUDE.md:**
    - Read APOLLO-BOOTSTRAP.md as template
    - Replace all `{{PLACEHOLDER}}` blocks with user's answers:
      - `{{DATE}}`: current date
      - `{{USER_NAME}}`: their name
      - `{{USER_BACKGROUND}}`: background info from research/imports
      - `{{TRIGGER_PHRASES}}`: formatted trigger phrase table rows
      - `{{REFERENCE_PATHS}}`: initial reference paths based on created folders
      - `{{TOOLS_SECTION}}`: MCP server table (only configured tools)
      - `{{ORGANIZATION_RULES}}`: vault organization instructions based on their method
      - `{{REVIEW_RITUALS}}`: daily/weekly review instructions (if opted in)
      - `{{COMMUNICATION_STYLE}}`: their chosen style with specific instructions
      - `{{WRITING_STYLE}}`: their writing preferences
      - `{{CUSTOM_PREFERENCES}}`: any additional preferences from conversation
    - Write the completed CLAUDE.md

30. **Create supporting files:**
    - README files for each project folder created
    - README files for each area folder created
    - Remove FIRST_RUN marker: `rm FIRST_RUN`

31. **If auto-sync opted in:** update `.claude/settings.json` with hooks

32. **Verify setup:**
    ```bash
    pnpm vault:stats
    ```

33. **Show summary and next steps:**

```markdown
## Setup Complete!

**Your vault is configured.** Here's what was set up:

- Name: [name]
- Organization: [method]
- Projects: [list]
- Areas: [list]
- Daily Journal: [enabled/disabled]
- Weekly Review: [enabled/disabled] ([day])
- Auto-sync: [enabled/disabled]
- Council Perspectives: [list]
- Gemini Vision: [configured/not configured]
- Firecrawl: [configured/not configured]

**Try these next:**
- `/thinking-partner` - Explore an idea
- `/council [question]` - Get multiple perspectives
- `/daily-review` - End of day reflection
- Drop files in 00_Inbox/ and run `/inbox` to organize them

**Your CLAUDE.md is alive.** It will grow and update as you use the vault. Claude will proactively load context and maintain reference paths.

**Works everywhere:** Claude Code terminal, Claude Code desktop app, or multiple instances at once.
```

## Important Notes

- **One question at a time.** Don't overwhelm with multiple questions.
- **The conversation IS the setup.** Don't rush through it.
- **Everything is optional.** Only enable what the user actually wants.
- **Import is powerful.** Encourage dropping files for a richer initial setup.
- **CLAUDE.md is the product.** The quality of the generated CLAUDE.md determines the quality of every future session.
