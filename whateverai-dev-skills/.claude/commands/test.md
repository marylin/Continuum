Run tests. If $ARGUMENTS given, run only matching tests. Otherwise full suite.

- Use project's existing framework. Install Playwright if needed (no asking).
- Headless mode. No screenshots unless debugging a failure.
- If fail from implementation → fix + re-test silently until passing.
- If fail from out of scope → show options (A: fix now, B: skip + log, C: separate task).
- Diff behavior between main and changes when relevant.
- Never mark done without proving it works.

Reply with ONLY:
✅ [count] passed | ❌ [count] failed | ⏭ [count] skipped
[If failures: one line per failure with file:line and reason]

Target: $ARGUMENTS
