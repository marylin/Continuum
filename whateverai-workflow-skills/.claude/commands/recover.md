# Recover Session

Recover work from a Claude CLI session that ended unexpectedly.

**NOTE:** For resuming planned features (with progress files), use `/resume` instead.

## Phase 1: Check crash logs (active-changes.log)

1. Check `~/.claude/sessions/active-changes.log` and `~/.claude/sessions/active-changes-*.log`
2. If no logs found, skip to Phase 2
3. For each log:
   a. Parse `# SESSION` headers for `cwd`, `sid`, `started` (multi-section = one session from /compact)
   b. Extract unique EDIT/WRITE file paths and COMMIT history
   c. Extract last `STATE:` line
4. Determine each file's state:
   - `git status --porcelain -- <file>` shows it → **still modified** (~)
   - `git log --oneline --since="<started>" -- <file>` has commits → **committed** (+)
   - Neither → **lost** (x)
5. If in a project dir, filter logs to that project. At multi-project root, group by project.

6. Present:
   ```
   Crashed session recovered:
   Project: <name> | Task: <STATE or "unknown">

   Files (<N> edits across <M> files):
     ~ src/api/routes.ts -- still modified
     + src/middleware/auth.ts -- committed (abc1234)
     x tests/auth.test.ts -- lost

   Commits: abc1234 feat(auth): add session middleware

   Resume from here, start fresh with this context, or discard?
   ```

7. **Resume** → continue working, delete logs. **Fresh** → present as context. **Discard** → delete logs.

## Phase 2: Legacy session JSON files

8. Scan `~/.claude/sessions/session-*.json` for `"status": "active"`
9. Filter by project if in a project dir; group by project otherwise
10. If no sessions found: "No crashed sessions to recover. Did you mean /resume?"
11. For selected session, read the state file from JSON's `state_file` field
    - If state file missing: "Session index found but state file missing. Removing stale entry." → delete JSON
12. Present recovery summary and ask: Resume, start fresh, or discard?

## Edge Cases
- No logs AND no JSONs: "No crashed sessions. Did you mean /resume?"
- Log with no EDIT/WRITE entries: show task only, note "no file changes tracked"
- Sessions older than 7 days: flag as "likely stale" but allow recovery
- Not a git repo: skip file status analysis

$ARGUMENTS
