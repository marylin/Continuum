#!/usr/bin/env bash
# Stop hook: assemble clean session JSON from append-only log, then delete log
# Trigger: Stop (matcher "")
# Token cost: 0 (command hook, no LLM)

SESSIONS_DIR="$HOME/.claude/sessions"
LOG="$SESSIONS_DIR/active-changes.log"

# No log = nothing to assemble
[ ! -f "$LOG" ] && exit 0
# Empty log = nothing useful
[ ! -s "$LOG" ] && exit 0

# Find jq
JQ=$(command -v jq 2>/dev/null)
if [ -z "$JQ" ]; then
  JQ="$HOME/AppData/Local/Microsoft/WinGet/Packages/jqlang.jq_Microsoft.Winget.Source_8wekyb3d8bbwe/jq.exe"
fi

# Parse last SESSION header (in case of multi-section from /compact)
LAST_HEADER=$(grep '^# SESSION' "$LOG" | tail -1)
CWD=$(echo "$LAST_HEADER" | sed -n 's/.*cwd=\([^ ]*\).*/\1/p')
SID=$(echo "$LAST_HEADER" | sed -n 's/.*sid=\([^ ]*\).*/\1/p')
STARTED=$(grep '^# SESSION' "$LOG" | head -1 | sed -n 's/.*started=\(.*\)/\1/p')

[ -z "$SID" ] && exit 0

# Extract last STATE line
STATE_LINE=$(grep '^STATE:' "$LOG" | tail -1 | sed 's/^STATE: *//')
[ -z "$STATE_LINE" ] && STATE_LINE="unknown"

PROJECT_NAME=$(basename "$CWD")
NOW=$(date +%Y-%m-%dT%H:%M:%S%z)

# Capture final git status snapshot
FINAL_STATUS=""
if [ -n "$CWD" ] && [ -d "$CWD" ]; then
  FINAL_STATUS=$(git -C "$CWD" status --porcelain 2>/dev/null || true)
fi

# Write completed session JSON
if [ -x "$JQ" ]; then
  "$JQ" -n \
    --arg sid "$SID" \
    --arg project "$CWD" \
    --arg project_name "$PROJECT_NAME" \
    --arg skill "$STATE_LINE" \
    --arg started "$STARTED" \
    --arg updated "$NOW" \
    '{
      session_id: $sid,
      project: $project,
      project_name: $project_name,
      skill: $skill,
      started: $started,
      updated: $updated,
      status: "completed",
      state_file: null,
      graceful: true
    }' > "$SESSIONS_DIR/session-${SID}.json"
else
  # Fallback: write JSON manually if jq is missing
  cat > "$SESSIONS_DIR/session-${SID}.json" << ENDJSON
{
  "session_id": "$SID",
  "project": "$CWD",
  "project_name": "$PROJECT_NAME",
  "skill": "$STATE_LINE",
  "started": "$STARTED",
  "updated": "$NOW",
  "status": "completed",
  "state_file": null,
  "graceful": true
}
ENDJSON
fi

# Delete the log (graceful exit = nothing to recover)
rm -f "$LOG"
