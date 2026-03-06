# Apollo Vault Commands

Pre-configured commands for your Claude Code + Obsidian workflow.

## Available Commands

### /init-bootstrap
Setup wizard. Configures your vault, imports existing notes, sets up intelligence features.

### /council
Think through a problem from multiple genuine perspectives. Each perspective agent doesn't know about the others, producing authentic reasoning instead of performative debate.

### /thinking-partner
Collaborative thinking through careful questioning. Stays in exploration mode, resists jumping to solutions.

### /daily-review
End-of-day reflection. Quick check-in on progress, patterns, and insights. 5-10 minutes max.

### /weekly-synthesis
Two-phase weekly review: autonomous retrospective (pattern analysis) + interactive prospective (planning).

### /inbox
Process and organize items in your Inbox folder. Handles chat exports from ChatGPT, Gemini, and other LLMs.

### /research-assistant
Deep research and synthesis across your vault.

### /add-frontmatter
Add or update YAML frontmatter properties on notes.

### /create-command
Build new custom commands for your workflow.

### /de-ai-ify
Remove AI-generated jargon and restore human voice to text.

### /release
Create a new release with version bump, changelog, and git tag.

### /upgrade
Upgrade Apollo Vault with latest features.

## Creating Custom Commands

1. Create a new `.md` file in this directory
2. Name it descriptively (kebab-case)
3. Structure with: role definition, process steps, output format
4. Use with: `/[command-name]`

## Tips

- Commands are structured prompts, not code
- Modify them based on your needs
- Combine commands for complex workflows
- The best commands emerge from your actual workflows
