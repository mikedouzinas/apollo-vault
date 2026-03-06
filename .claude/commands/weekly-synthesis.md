---
description: Weekly pattern recognition and synthesis with two phases - autonomous retrospective and interactive prospective planning
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
---

# Weekly Synthesis - Two-Phase Review

Guide the user through a weekly review with deep pattern recognition and forward planning.

**Two Phases:**
1. **Phase 1: Retrospective Synthesis** - What happened last week? Patterns, analysis, accountability. Claude runs this autonomously.
2. **Phase 2: Prospective Planning** - What's coming? Interactive planning with the user.

---

# PHASE 1: RETROSPECTIVE SYNTHESIS (Autonomous)

Run this phase automatically before engaging the user.

## Step 0: Establish Ground Truth

```bash
date "+%A, %B %d, %Y"
```

Calculate:
- **Week range** (Monday-Sunday of the past week)
- **Previous synthesis** to compare (find most recent in `06_Metadata/Weekly Reviews/`)

## Step 1: Vault Changes (Last 7 Days)

**Search ALL folders, not just Projects.**

```bash
# All modified .md files in last 7 days
find . -name "*.md" -mtime -7 -type f 2>/dev/null | grep -v node_modules | grep -v .trash

# Check specific high-activity locations
find ./01_Projects -name "*.md" -mtime -7 2>/dev/null
find ./02_Areas -name "*.md" -mtime -7 2>/dev/null
find ./06_Metadata -name "*.md" -mtime -7 2>/dev/null
```

**Look for:**
- Project activity and progress
- New areas of exploration
- Daily journal entries
- What's conspicuously absent?

## Step 2: Load Previous Synthesis

Read the most recent synthesis in `06_Metadata/Weekly Reviews/` and identify:
- What goals were set
- What patterns were surfaced
- What was the experiment for the week

## Step 3: Pattern Analysis

Based on Steps 0-2, assess:

**Project Progress:**
- What shipped or progressed?
- Which projects got attention?
- Is there forward movement?
- What's stalled and why?

**Energy Audit:**
- What types of work gave energy?
- What drained energy?
- What kept pulling the user into unproductive patterns?

**Where Settling Occurred:**
- Where was "good enough" chosen over pushing further?
- Is there a pattern in where settling happens?

**What's Being Avoided:**
- What hasn't been touched despite being important?
- What keeps getting deferred?

**Comparison to Last Week:**
- Did patterns from the previous synthesis shift?
- Were stated goals met?

## Step 4: Write Synthesis

Create file at: `06_Metadata/Weekly Reviews/[YYYY-MM-DD] - Weekly Synthesis.md`

Use the output format template below.

---

# PHASE 2: PROSPECTIVE PLANNING (Interactive)

After completing Phase 1, present the synthesis to the user and ask: **"Ready to plan the upcoming week?"**

## Step 5: Calendar and Deadline Check

If MCP servers are configured (check `.claude/vault-config.json` for available tools):
- Check calendar for upcoming events
- Check email for pending items
- Check any task management tools

If no MCP servers: ask the user what's coming up.

## Step 6: Check for Deadlines

- Read any task/deadline files the user has set up
- Check project folders for approaching milestones
- Ask: "Anything else coming up that's not captured?"

## Step 7: Week Plan Conversation

Discuss with the user:
- **Primary focus:** What's the ONE thing this week?
- **Constraints:** What's immovable?
- **Experiment:** What's being tried differently?
- **Accountability:** What will we check next week?

---

## Output Format

```markdown
# Weekly Synthesis - [Date Range]

## Week at a Glance

| Metric | Count |
|--------|-------|
| Notes Created | X |
| Notes Edited | Y |

**Projects Touched:**
- [List projects with activity]

**Major Accomplishments:**
- [2-4 concrete wins]

---

## Key Themes

What defined this week? 2-3 recurring threads.

1. **[Theme 1]:** Brief explanation
2. **[Theme 2]:** Brief explanation

---

## Major Insights

Realizations that landed this week.

1. **[Insight]:** What it means, why it matters
2. **[Insight]:** What it means, why it matters

---

## Project Progress

### [Project Name]
**Status:** [what progressed]
**Blocked:** [if anything]
**Next:** [what's next]

---

## Energy Audit

**What gave energy:**
-

**What drained energy:**
-

**What to adjust:**
-

---

## Patterns Surfaced

**Recurring behavior:**
-

**Where settling occurred:**
-

**What's being avoided:**
-

**Comparison to last week:**
-

---

## Questions Emerging

Open questions without answers yet.

1.
2.

---

## Connections Made

Cross-domain links.

- [Connection 1]
- [Connection 2]

---

## Next Week

**Primary focus:**
**Experiment:**
**Accountability marker:**

---

*Synthesis completed: [Date/Time]*
*Phase 1 complete. Phase 2 complete: Y/N*
```

## Tone

- **Direct**: If something's off, say it
- **Grounded**: Connect patterns to concrete behavior
- **Challenging**: Call out inconsistencies and avoidance
- **Pattern-focused**: Reference previous weeks for trend spotting

## When to Use

- Weekly, on whatever day the user configured during setup
- Check `vault-config.json` for `weeklyReview.day` and `weeklyReview.focusAreas`
- If no preferences set, default to Sunday

## Remember

- Pattern recognition over productivity tracking
- The review should model the behavior it tracks (be high-signal, not noise)
- Challenge directly when needed
- The user opted into being pushed, not coddled
