# Resume Feature

Resume work on an in-progress feature. If $ARGUMENTS given, match that feature. Otherwise find the most recent active progress file in `docs/05-Plans/` (ignore `docs/09-Archive/`).

If no progress files found in docs/05-Plans/, suggest: "No plan progress found. Did you mean /recover for crashed sessions?"

Steps:
1. Check docs/06-Development/lessons.md for relevant lessons before resuming (skip if the file doesn't exist — it's optional)
2. Find the progress file locally in `docs/05-Plans/`
3. If the progress file is MISSING (deleted, lost on branch switch, CLI crash):
   - Check the plan file for the feature — it cannot be reconstructed automatically without Linear
   - Suggest: "Progress file missing. If you have a Linear issue linked, use /resume with the plan-linear variant. Otherwise, reconstruct manually from the plan file."
4. Read ONLY the top section of the progress file (current state + next steps)
5. Read the plan file ONLY for the next incomplete task's details
6. Do NOT re-read completed task details or archived files
7. Continue building from the next [ ] or [~] task
8. Update progress file as you go — one line per task, no prose
9. Do not ask me anything — just resume and work until all tasks are done
10. If context gets close to limit: save state → commit → /compact → resume automatically
11. Do NOT stop between tasks to ask for permission or confirmation
12. If something goes sideways, STOP and re-plan rather than pushing through a broken approach

$ARGUMENTS
