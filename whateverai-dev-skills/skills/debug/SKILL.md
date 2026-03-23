---
name: debug
description: Investigate and fix a bug or unexpected behavior
argument-hint: <issue description>
---

# Debug Issue

Investigate and fix a bug or unexpected behavior.

1. Trace the code path from entry point to problem area
2. Check `git log --oneline -20` for recent changes that may have introduced the issue
3. Identify root cause -- check logic, types, config, race conditions, environment
4. If the fix is clear: implement it and verify
5. If multiple causes are possible: rank by likelihood, fix the most probable first

$ARGUMENTS
