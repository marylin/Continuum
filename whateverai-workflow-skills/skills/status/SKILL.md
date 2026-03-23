---
name: status
description: Show current status of an active plan from docs/05-Plans/
argument-hint: [feature name]
---

# Show Status

Find the active progress file in `docs/05-Plans/` (ignore `docs/09-Archive/`). If $ARGUMENTS given, match that feature name.

Reply with ONLY this format, nothing else:

## [Feature Name]
Done: [count] | In Progress: [count] | Remaining: [count] | Blocked: [count]

[~] Current task — what's happening
[ ] Next up — brief
[!] Blocked — why (if any)

Do not list completed tasks unless I ask. Do not read archived plans.

$ARGUMENTS
