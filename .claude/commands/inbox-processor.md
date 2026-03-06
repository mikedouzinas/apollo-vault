---
description: Process and organize items in your Inbox folder, including chat exports from other LLMs
argument-hint: "(optional) 'setup' for first-time processing during init"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
---

# Inbox Processor - Organize and Import

Process items in `00_Inbox/`, including chat exports from other LLMs.

## Task

### 1. Scan the Inbox

```bash
ls -lah 00_Inbox/
```

**Exclude from processing:**
- README.md
- Welcome.md
- .DS_Store

### 2. Analyze Each Item

For each file, determine:
- **What is it?** (capture, research, reference, chat export, document, idea)
- **Format?** (markdown, JSON, plain text, PDF)
- **Related to what?** (which project/area)
- **Should it move or stay?**

### 3. Chat Export Detection

**ChatGPT JSON export:**
- Look for files with `.json` extension containing `"conversations"` array
- Each conversation has `"title"`, `"mapping"` with message nodes
- Extract: key decisions, insights, project context, recurring themes
- Save extracted insights as individual notes in appropriate folders

**Gemini / Other LLM text:**
- Look for conversational patterns (alternating speakers)
- Detect "User:" / "Assistant:" or similar turn markers
- Extract the same types of insights

**Any LLM output:**
- Look for structured knowledge, decisions, creative output
- Extract and file appropriately

### 4. Categorization Rules

#### To Projects (`01_Projects/`)
**Indicators:**
- Has a deadline or specific outcome
- Related to an active project
- Action-oriented, time-bound

#### To Areas (`02_Areas/`)
**Indicators:**
- Ongoing responsibility, no end date
- Life domain maintenance
- Recurring theme

#### To Resources (`03_Resources/`)
**Indicators:**
- Reference material, knowledge base
- Articles, research, tutorials
- Information to reference later, not act on

#### To Archive (`04_Archive/`)
**Indicators:**
- Completed work
- Old and no longer active
- Historical context only

#### Stay in Inbox
**Legitimately belongs here:**
- Items not yet ready to organize
- Active reference holds
- Things still being processed mentally

#### Delete
**Truly worthless:**
- Redundant duplicates
- Test files
- Temporary notes with no lasting value

### 5. Present Suggestions

**Format:**

```markdown
## Inbox Processing Results

### Items to Move

**File:** [filename]
**Type:** [capture/research/reference/chat-export/idea]
**Destination:** [folder path]
**Reason:** [why this categorization]
**Related to:** [existing notes it connects to, if any]

### Items to Extract & Split

**File:** [filename]
**Problem:** Too large or multi-topic
**Action:** Extract [sections] to [destinations]

### Chat Exports Found

**File:** [filename]
**Source:** [ChatGPT/Gemini/Other]
**Conversations:** [count]
**Key themes:** [what's in there]
**Action:** Extract insights to [suggested locations]

### Items to Keep in Inbox

**File:** [filename]
**Why:** [legitimate reference hold reason]

### Items to Delete

**File:** [filename]
**Why:** [truly worthless]

### Connections Spotted

**Pattern:** [theme across multiple notes]
**Opportunity:** [could combine or link these items]
```

### 6. Execute with Confirmation

- Present all suggestions to the user
- Wait for confirmation before moving any files
- Move files using Bash `mv` command
- After moves: if significant new folders were created, suggest updating CLAUDE.md reference paths

## Setup Mode

When called during `/init-bootstrap` (argument contains "setup"):

- Focus on **learning about the user** from the dropped files
- Extract: preferences, project context, recurring themes, expertise
- Use findings to suggest projects, areas, and vault structure
- Report back what was learned to inform the rest of setup

## Tone

- **Respect the inbox** - It's not a failure if items stay there
- **Context-aware** - Suggest specific destinations based on existing vault structure
- **Pattern-spotting** - Look for themes across captures
- **Practical** - Only suggest moves that actually make sense

## Remember

- The inbox is a HOLD, not a QUEUE - processing isn't mandatory
- Some items legitimately live here
- Avoidance is data - if something's been here for months, ask why
- After processing, note any connections between items and existing vault content
- Chat exports are gold mines - extract insights carefully, don't just file the raw export
