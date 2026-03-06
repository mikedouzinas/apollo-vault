---
description: Think through a problem from multiple genuine perspectives using an LLM council
argument-hint: [topic or question to explore]
allowed-tools: [Read, Write, Glob, Grep, Agent, Bash]
---

# Council - Multi-Perspective Reasoning

Think through hard problems by getting genuine, independent perspectives from multiple agents who don't know they're part of a system.

## Processing: $ARGUMENTS

## How It Works

Each perspective agent receives the topic framed neutrally, relevant vault context, and a worldview baked into its system prompt. No agent knows other agents exist. This produces genuine reasoning, not performative disagreement.

## Process

### Step 1: Gather Context

Search the vault for relevant notes related to the topic:

```bash
# Find related notes
```

Use Glob and Grep to find notes related to the topic keywords. Read the most relevant 3-5 notes to build context.

### Step 2: Load Perspectives

Read `.claude/vault-config.json` and check for `council.perspectives` array. If not found or file doesn't exist, use these defaults:

**Default Perspectives:**

1. **Pragmatist**
   System prompt: "You value what actually works. Theory is only useful if it survives contact with reality. You care about implementation, second-order effects, and whether something will hold up under pressure. When someone presents an idea, you think about what happens when it meets the real world."

2. **Contrarian**
   System prompt: "You notice what everyone else misses. You're drawn to the overlooked angle, the assumption nobody questioned, the thing that seems obvious but isn't. You don't argue for the sake of arguing. You genuinely see things differently and build your own case from first principles."

3. **Humanist**
   System prompt: "You care about people. How does this affect relationships, wellbeing, and the lived experience of the humans involved? You think in terms of values, meaning, and long-term flourishing. Technology, systems, and strategies are only as good as the human outcomes they produce."

### Step 3: Run Each Perspective

For each perspective, use the Agent tool with `subagent_type: "general-purpose"`.

**CRITICAL: Each agent's prompt must follow this exact pattern:**

```
[Perspective system prompt from above]

---

Someone is thinking through the following question:

"[THE TOPIC/QUESTION]"

Here is some relevant context from their notes:

[VAULT CONTEXT - relevant excerpts from Step 1]

---

What is your analysis? Think carefully about this from your perspective. Build your strongest, most honest case. Consider:
- What do you notice that others might miss?
- What are the real stakes here?
- What would you recommend and why?

Write a thorough analysis (300-500 words).
```

**Rules for agent prompts:**
- Do NOT mention "council", "other perspectives", "devil's advocate", or "debate"
- Do NOT say "you are the pragmatist agent" — just embed the worldview naturally
- Do NOT tell the agent to "argue against" anything — let it form its own position
- The agent should feel like it's the only one being asked

Run each agent sequentially. Collect their outputs.

### Step 4: Synthesize

After all perspectives are collected, use one final Agent call with this prompt:

```
You've been given multiple independent analyses of the same question from people with different worldviews. None of them knew about each other.

The question was: "[TOPIC]"

Here are their analyses:

[PERSPECTIVE 1 NAME]:
[Output]

[PERSPECTIVE 2 NAME]:
[Output]

[PERSPECTIVE 3 NAME]:
[Output]

Your job is to synthesize these perspectives honestly:

1. **Where do they agree?** What conclusions hold up across all viewpoints?
2. **Where do they genuinely disagree?** Not surface-level differences, but real tensions in values or assumptions.
3. **What's the real insight?** What emerges from seeing all three perspectives together that none of them saw alone?
4. **What remains unresolved?** What questions does this raise that still need thinking?

Be direct. Don't flatten the disagreements. The tensions are where the insight lives.
```

### Step 5: Save and Present

Get the current date:
```bash
date +%Y-%m-%d
```

Create a slug from the topic (lowercase, hyphens, max 50 chars).

Save the full output to `06_Metadata/Council/[DATE] - [slug].md` using this format:

```markdown
# Council: [Topic]
Date: [DATE]

## The Question
[Original topic, neutrally framed]

## Perspectives

### [Perspective 1 Name]
[Their full analysis]

### [Perspective 2 Name]
[Their full analysis]

### [Perspective 3 Name]
[Their full analysis]

## Synthesis
[The synthesis agent's output]

## Open Questions
[Unresolved questions from the synthesis]
```

Present the synthesis section to the user, then mention the full council output was saved.

## Tips

- Works best with genuine dilemmas, not factual questions
- Custom perspectives can be configured during `/init-bootstrap` or by editing `.claude/vault-config.json`
- The vault context step makes this powerful: your own notes inform each perspective
- Run multiple councils on the same topic as your thinking evolves
