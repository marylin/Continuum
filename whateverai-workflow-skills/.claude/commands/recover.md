# Recover Session

Recover work from a Claude CLI session that ended unexpectedly.

**NOTE:** This command is for crashed/interrupted sessions. For resuming planned features (with progress files in docs/05-Plans/), use `/resume` instead.

## Steps

### Phase 1: Check for v2 crash logs (active-changes.log)

1. Check for `~/.claude/sessions/active-changes.log`
2. Also scan for `~/.claude/sessions/active-changes-*.log` files (renamed crash logs from previous sessions that were never recovered)
3. If no log files found, skip to Phase 2

4. For each log file found:
   a. Parse `# SESSION` header(s) for `cwd`, `sid`, `started`
   b. If multiple `# SESSION` headers exist (from `/compact`), treat all sections as one continuous session. Use the first `started` timestamp and the last `cwd`.
   c. Extract unique EDIT/WRITE file paths (deduplicated, ordered by last appearance)
   d. Extract COMMIT history (hash + subject lines)
   e. Extract last `STATE:` line (if any)

5. For each tracked file, determine current state:
   - Run `git status --porcelain -- <file>` in the project cwd. If it appears, mark as **still modified** (~)
   - If not in git status, run `git log --oneline --since="<session_started>" -- <file>`. If commits found, mark as **committed** (+)
   - If neither, mark as **lost** (x) -- was tracked as modified during session, now clean

6. If inside a recognized project directory, filter to logs matching the current project path
7. If at a multi-project root, show all logs grouped by project

8. Present recovery summary:
   ```
   Crashed session recovered from change log:
   Project: <project_name>
   Task: <STATE line or "unknown">
   Duration: <calculated from started to last log entry>

   Files tracked (<N> edits across <M> files):
     ~ src/api/routes.ts -- still modified (unstaged)
     + src/middleware/auth.ts -- committed (abc1234)
     x tests/auth.test.ts -- lost (was modified, now clean)

   Commits during session:
     abc1234 feat(auth): add session middleware

   Resume from here, start fresh with this context, or discard?
   ```

9. **Resume** -- present the summary as context, continue working. Delete log files.
10. **Start fresh** -- present as background context, let user direct. Delete log files.
11. **Discard** -- delete `active-changes.log` and any `active-changes-*.log` files

### Phase 2: Check for v1 session JSON files (legacy fallback)

12. Scan `~/.claude/sessions/` for files matching `session-*.json` with `"status": "active"`
13. If inside a recognized project directory, filter to sessions matching the current project path
14. If at a multi-project root or any non-project directory, show all stale sessions grouped by project
15. If no stale sessions found (and no logs from Phase 1): print "No crashed sessions to recover. All clean." and stop
16. If one stale session found for this project, show its summary directly
17. If multiple stale sessions found, list them and ask which to recover
18. For the selected session, read the per-project state file at the path in the JSON's `state_file` field
    - If `state_file` is null (v2 completed session): skip -- these have `"status": "completed"` and should already be filtered out
19. If the state file is missing but the JSON exists: print "Session [id] index found but state file is missing (branch switch?). Removing stale entry." -- delete the JSON and stop

20. Present the recovery summary showing: skill, current state, completed tasks, next tasks, last actions, checkpoint data (if present)
21. Ask: "Resume from here, or start fresh with this context?"
22. **Resume** -- re-invoke the original skill with the checkpoint data and task state as context
23. **Start fresh** -- present the summary as background context, let the user direct next steps
24. **Clean/discard** -- delete both the per-project `.session-<id>.md` file and the `~/.claude/sessions/session-<id>.json` file
25. After any recovery or discard action, clean up session files

## Edge Cases
- No logs AND no session JSONs: "No crashed sessions to recover. All clean. Did you mean /resume for planned features?"
- Log exists but has no EDIT/WRITE entries (only STATE line): show task description, note "no file changes tracked"
- Multiple renamed crash logs: list all, let user pick or discard all
- Log has entries from multiple projects (user cd'd mid-session): group by cwd, present separately
- Session older than 7 days: flag as "old -- likely irrelevant" but still allow reading
- Git not available or not a git repo: skip file status analysis with note
- Log has multi-section format (from /compact): treat as one continuous session

$ARGUMENTS
