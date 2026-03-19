# Smart Skill Router

Smart skill router. Describe what you want to do and I'll find the right skill.

If no arguments provided, ask: "What would you like to do? Describe your task and I'll find the right skill."

## Steps

1. Read `~/.claude/skills-reference.md` for the full categorized skill catalog
2. If the file does not exist, say: "Skills catalog not found. Run /catalog first to generate it." and stop.
3. Check the "Last updated" date in the file header. If older than 14 days, warn: "Skills catalog is [N] days old. Run /catalog to refresh."
4. Parse the user's intent from: $ARGUMENTS
5. Match against skill names, descriptions, and category context
6. **Load usage data:** Read `~/.claude/skill-usage.jsonl` (if it exists). Count invocations per skill in the last 30 days. Compute a frequency score:
   - 5+ invocations in 30 days → high boost
   - 1-4 invocations → medium boost
   - 0 invocations or file missing → no boost
7. Score each skill by relevance:
   - Direct keyword match in skill name or command → high weight
   - Keyword match in description → medium weight
   - Category context match → low weight
   - **Usage frequency (from step 6) → bonus weight** (tiebreaker that elevates frequently-used skills)
8. Apply duplicate resolution: prefer user commands over plugin skills when command names collide

**If one clear best match** (top score significantly above second):
```
Best match: [skill-name] ([source]) — used [N] times this month
"[description]"

Use this skill? (yes / show alternatives / skip)
```
(Omit the usage count if 0 — keep output clean.)

**If multiple strong matches** (top 3 within close score range):
```
Multiple skills could help:
1. [skill-name] ([source]) — [description] (used [N]x)
2. [skill-name] ([source]) — [description] (used [N]x)
3. [skill-name] ([source]) — [description] (used [N]x)

Which one? (number / skip)
```
(Omit `(used 0x)` entries — only show count for skills with usage.)

**If no match found:**
Say "No matching skill found. Proceeding with your request." and handle the task described in $ARGUMENTS directly — no skill invocation, just do the work.

9. On user confirmation, invoke the selected skill via the Skill tool, passing the original $ARGUMENTS as the skill arguments
10. **Track the invocation:** After successfully invoking a skill, append a line to `~/.claude/skill-usage.jsonl`:
    ```json
    {"skill":"/skill-name","timestamp":"2026-03-19T14:00:00Z","source":"do-router"}
    ```
    Use the actual skill command (e.g., `/qa`, `/plan`) and current ISO 8601 timestamp. Create the file if it doesn't exist.
11. If user says "show alternatives", show the next 3 best matches
12. If user says "skip", proceed without a skill — handle the task directly using $ARGUMENTS as context

## Edge Cases
- Empty $ARGUMENTS → ask what the user wants to do
- Deprecated skills are never proposed (they are filtered out by /catalog)
- If the catalog is more than 14 days old, warn but still proceed with matching
- `skill-usage.jsonl` missing or empty → proceed without usage boost (no error)
- Malformed lines in usage file → skip them silently

$ARGUMENTS
