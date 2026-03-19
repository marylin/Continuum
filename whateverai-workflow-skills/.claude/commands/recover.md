Recover work from a Claude CLI session that ended unexpectedly.

**NOTE:** This command is for crashed/interrupted sessions. For resuming planned features (with progress files in docs/05-Plans/), use `/resume` instead.

Steps:
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
9. Present the recovery summary showing: skill, current state, completed tasks, next tasks, last actions, and checkpoint data (if present)
10. Ask: "Resume from here, or start fresh with this context?"
11. **Resume** — re-invoke the original skill with the checkpoint data and task state as context
12. **Start fresh** — present the summary as background context, let the user direct next steps
13. **Clean/discard** — delete both the per-project `.session-<id>.md` file and the `~/.claude/sessions/session-<id>.json` file
14. After any recovery or discard action, clean up both session files

Edge cases:
- Session file missing but JSON exists → clean up JSON, notify user
- JSON missing but session file exists → read session file directly, recover from it
- Session older than 7 days → flag as "old — likely irrelevant" but still allow reading
- If no session state found, suggest: "No session state found. Did you mean /resume for planned features?"

Feature: $ARGUMENTS
