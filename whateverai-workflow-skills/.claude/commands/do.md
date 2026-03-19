Smart skill router. Describe what you want to do and I'll find the right skill.

If no arguments provided, ask: "What would you like to do? Describe your task and I'll find the right skill."

## Steps

1. Read `~/.claude/skills-reference.md` for the full categorized skill catalog
2. If the file does not exist, say: "Skills catalog not found. Run /catalog first to generate it." and stop.
3. Check the "Last updated" date in the file header. If older than 14 days, warn: "Skills catalog is [N] days old. Run /catalog to refresh."
4. Parse the user's intent from: $ARGUMENTS
5. Match against skill names, descriptions, and category context
6. Score each skill by relevance:
   - Direct keyword match in skill name or command → high weight
   - Keyword match in description → medium weight
   - Category context match → low weight
7. Apply duplicate resolution: prefer user commands over plugin skills when command names collide

**If one clear best match** (top score significantly above second):
```
Best match: [skill-name] ([source])
"[description]"

Use this skill? (yes / show alternatives / skip)
```

**If multiple strong matches** (top 3 within close score range):
```
Multiple skills could help:
1. [skill-name] ([source]) — [description]
2. [skill-name] ([source]) — [description]
3. [skill-name] ([source]) — [description]

Which one? (number / skip)
```

**If no match found:**
Say "No matching skill found. Proceeding with your request." and handle the task described in $ARGUMENTS directly — no skill invocation, just do the work.

8. On user confirmation, invoke the selected skill via the Skill tool, passing the original $ARGUMENTS as the skill arguments
9. If user says "show alternatives", show the next 3 best matches
10. If user says "skip", proceed without a skill — handle the task directly using $ARGUMENTS as context

## Edge Cases
- Empty $ARGUMENTS → ask what the user wants to do
- Deprecated skills are never proposed (they are filtered out by /catalog)
- If the catalog is more than 14 days old, warn but still proceed with matching

Feature: $ARGUMENTS
