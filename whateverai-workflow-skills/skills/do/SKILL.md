---
name: do
description: Smart skill router — describe what you want to do and the right skill is found and invoked
argument-hint: <what you want to do>
---

# Smart Skill Router

Describe what you want to do and I'll find the right skill.

If no arguments provided, ask: "What would you like to do?"

## Steps

1. Read `~/.claude/skills-reference.md`. If missing: "Run /catalog first." and stop.
2. If catalog older than 14 days, warn but proceed.
3. Parse intent from: $ARGUMENTS
4. Load `~/.claude/skill-usage.jsonl` (if exists). Boost frequently-used skills as tiebreaker.
5. Score each skill: name/command match (high) > description match (medium) > category match (low) + usage boost.
6. Prefer user commands over plugin skills on name collision.

**One clear match:**
```
Best match: [skill] ([source])
"[description]"
Use this skill? (yes / show alternatives / skip)
```

**Multiple strong matches (top 3):**
```
1. [skill] ([source]) — [description]
2. [skill] ([source]) — [description]
3. [skill] ([source]) — [description]
Which one? (number / skip)
```

**No match:** "No matching skill found." — handle the task directly.

7. On confirmation, invoke the skill via Skill tool with original $ARGUMENTS.
8. Log to `~/.claude/skill-usage.jsonl`: `{"skill":"/name","timestamp":"ISO8601","source":"do-router"}`
9. "show alternatives" → next 3 matches. "skip" → handle task directly.

$ARGUMENTS
