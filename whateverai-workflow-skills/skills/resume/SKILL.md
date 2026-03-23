---
name: resume
description: Resume work on an in-progress feature from its docs/05-Plans/ progress file
argument-hint: [feature name]
---

# Resume Feature

Resume work on an in-progress feature. If $ARGUMENTS given, match that feature. Otherwise find the most recent active progress file in `docs/05-Plans/` (ignore `docs/09-Archive/`).

If no progress files found: "No plan progress found. Did you mean /recover for crashed sessions?"

1. Check docs/06-Development/lessons.md for relevant lessons (skip if missing)
2. Find and read the progress file -- ONLY the current state + next steps
3. If progress file is MISSING: suggest reconstructing from plan file or Linear
4. Read the plan file ONLY for the next incomplete task's details
5. Continue from the next `[ ]` or `[~]` task
6. Update progress file as you go -- one line per task, no prose
7. Do not ask anything between tasks -- just work until done
8. If context limit approaching: save state, commit, /compact, resume
9. If something goes sideways: STOP and re-plan

$ARGUMENTS
