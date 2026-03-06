---
description: End-of-day reflection and insight capture
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
---

# Daily Review - End of Day Check-in

Quick end-of-day reflection focused on progress and patterns, not task completion checklists.

## Context

This review should be:
- **5-10 minutes max** - Not a burden, just a check-in
- **Pattern-catching** - Spot trends across days
- **Context-aware** - Saved where the work happened or in Daily Journal
- **Optional** - Skip if nothing significant happened

## Process

### 1. Quick File Scan

```bash
# What was modified today?
find . -name "*.md" -mtime 0 -type f | grep -v node_modules | grep -v .trash
```

### 2. Core Questions

Check `.claude/vault-config.json` for `dailyReview.questions`. If custom questions exist, use those. Otherwise use these defaults:

**Ask the user:**

1. **"What moved forward today?"**
   - What actually progressed, not just what was touched
   - Concrete outcomes, not activity

2. **"Where did you settle for 'good enough' when you could have pushed further?"**
   - Not self-judgment, just noticing
   - Why you settled (tired? avoiding? genuinely fine?)

3. **"What's one thing you learned or realized?"**
   - Could be technical, personal, or about how something works
   - Must be genuine insight, not surface-level

### 3. Capture (If Worth Remembering)

Check `vault-config.json` for `dailyJournal.enabled` and `dailyJournal.location` (defaults to `06_Metadata/Daily Journal/`).

If daily journal is enabled, add to today's entry:

```markdown
## [Date]

**What moved forward:**
-

**Where I settled:**
-

**Key realization:**
-

**Tomorrow's focus:**
-
```

If a realization connects to a specific project, also add a note there.

### 4. Pattern Check (Every Few Days)

Every 3-4 days, look at recent entries and ask:
- "What pattern is emerging in where you're settling?"
- "What types of work are giving you energy vs draining it?"
- "What keeps pulling you away from what matters?"

## What This Is NOT

- NOT a comprehensive task log
- NOT mandatory if nothing significant happened
- NOT generic gratitude journaling
- NOT longer than 10 minutes

## What This IS

- A reality check on how the day actually went
- Catching patterns before they become habits
- Capturing insights before they fade
- Optional, context-aware, and short

## Tone

- **Quick**: Spot-check, not therapy
- **Honest**: If you wasted the day, say it
- **Pattern-focused**: Looking for trends, not judging one day
- **Non-judgmental**: Off days happen, just notice them

## When to Use

**Good times:**
- End of a productive day (capture what worked)
- End of a scattered day (notice what pulled you off track)
- When you had a real insight worth remembering
- When you feel like you settled somewhere

**Skip it when:**
- Nothing significant happened
- Day was predetermined (travel, events)
- You're exhausted and it would just be noise

## Integration

Daily reviews feed the weekly synthesis (`/weekly-synthesis`). The weekly review looks at patterns across daily entries, not individual days. Light daily awareness supports weekly pattern recognition without becoming another ritual to feel guilty about.
