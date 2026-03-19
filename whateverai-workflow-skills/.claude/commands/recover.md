# Recover Session

Recover work from a Claude CLI session that ended unexpectedly.

**NOTE:** This command is for crashed/interrupted sessions. For resuming planned features (with progress files in docs/05-Plans/), use `/resume` instead.

## Steps

1. Scan `~/.claude/sessions/` for files matching `session-*.json` with `"status": "active"`
2. If inside a recognized project directory, filter to sessions matching the current project path
3. If at a multi-project root or any non-project directory, show all stale sessions grouped by project
4. If no stale sessions found: print "No crashed sessions to recover. All clean." and stop
5. If one stale session found for this project, show its summary directly
6. If multiple stale sessions found, list them and ask which to recover:
   ```
   Stale sessions:
   1. [skill] — [Current State line] ([time] ago)
   2. [skill] — [Current State line] ([time] ago)

   Which session? (number, "all" for summary of each, or "clean" to discard all)
   ```
7. For the selected session, read the per-project state file at the path in the JSON's `state_file` field
8. If the state file is missing but the JSON exists: print "Session [id] index found but state file is missing (branch switch?). Removing stale entry." — delete the JSON and stop

## File Change Analysis

9. **Check for a `## File Snapshot` section** in the session state file. If present, compare each listed file against current state:

   a. For each file in the snapshot, run `git status` and `git diff` to determine:
      - **Still pending** — file still has uncommitted changes matching the snapshot
      - **Committed** — file was committed since the crash (check `git log --oneline -5 -- <file>`)
      - **Lost** — file was in snapshot as modified but now shows no changes (reverted or lost)
      - **Partially lost** — file has changes but they differ from what was in progress

   b. Present the change analysis:
   ```
   File changes since crash:
     ✓ src/api/routes.ts — committed (abc1234: "feat: add auth routes")
     ~ src/utils/helpers.ts — still pending (unstaged changes)
     ✗ src/middleware/auth.ts — lost (was modified, now clean)
     ? tests/auth.test.ts — partially changed (current diff differs from session state)
   ```

   c. For files marked **lost**, check recovery options:
      - `git stash list` — check if changes were auto-stashed
      - `git reflog` — check for recent commits that were reset/amended away
      - Print actionable guidance:
      ```
      Recovery hints for lost files:
        src/middleware/auth.ts — try: git stash list | grep auth, or git reflog --all
      ```

   d. If no `## File Snapshot` section exists (older session format), skip this analysis and note: "No file snapshot in session state (pre-v1.1 format). Showing task state only."

## Recovery Options

10. Present the recovery summary showing: skill, current state, completed tasks, next tasks, last actions, checkpoint data (if present), and **file change analysis** (if available)
11. Ask: "Resume from here, or start fresh with this context?"
12. **Resume** — re-invoke the original skill with the checkpoint data and task state as context
13. **Start fresh** — present the summary as background context, let the user direct next steps
14. **Clean/discard** — delete both the per-project `.session-<id>.md` file and the `~/.claude/sessions/session-<id>.json` file
15. After any recovery or discard action, clean up both session files

## Edge Cases
- Session file missing but JSON exists → clean up JSON, notify user
- JSON missing but session file exists → read session file directly, recover from it
- Session older than 7 days → flag as "old — likely irrelevant" but still allow reading
- If no session state found, suggest: "No session state found. Did you mean /resume for planned features?"
- No `## File Snapshot` section → skip file analysis, show task state only (backwards compatible)
- Git not available or not a git repo → skip file analysis with note

$ARGUMENTS
