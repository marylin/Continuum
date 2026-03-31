#!/usr/bin/env bash
# PostToolUse hook: track Edit/Write file changes to append-only log
# Trigger: matcher "Edit|Write"
# Token cost: 0 (command hook, no LLM)

log_error() {
  mkdir -p "$HOME/.claude/debug" 2>/dev/null
  echo "$(date +%Y-%m-%dT%H:%M:%S%z) [track-file-change] $1" >> "$HOME/.claude/debug/hook-failures.log"
}

SESSIONS_DIR="$HOME/.claude/sessions"
LOG="$SESSIONS_DIR/active-changes.log"
STALE_THRESHOLD=900  # 15 minutes in seconds

# Find jq - same pattern as statusline-command.sh
JQ=$(command -v jq 2>/dev/null)
if [ -z "$JQ" ] || [ ! -x "$JQ" ]; then
  log_error "jq not found — install jq (https://jqlang.github.io/jq/) for session tracking"
  exit 0
fi

# Read stdin JSON
INPUT=$(cat)

# Extract fields
TOOL_NAME=$("$JQ" -r '.tool_name // empty' <<< "$INPUT")
FILE_PATH=$("$JQ" -r '.tool_input.file_path // empty' <<< "$INPUT")
CWD=$("$JQ" -r '.cwd // empty' <<< "$INPUT")
SID=$("$JQ" -r '.session_id // empty' <<< "$INPUT")

# Fallback session ID: generate a stable one if not provided
# Cannot use $$ (subprocess PID changes every invocation)
if [ -z "$SID" ]; then
  SID=$(printf '%04x%04x' $RANDOM $RANDOM)
fi

if [ -z "$FILE_PATH" ] || [ -z "$CWD" ]; then
  exit 0
fi

# Ensure sessions dir exists
mkdir -p "$SESSIONS_DIR"

# Normalize paths to forward slashes
CWD="${CWD//\\//}"
FILE_PATH="${FILE_PATH//\\//}"

NOW=$(date +%Y-%m-%dT%H:%M:%S%z)
NOW_EPOCH=$(date +%s)

# Handle existing log: age-based decision (not sid-based)
# - Fresh log (< 15 min): append new SESSION header (same session or /compact)
# - Stale log (>= 15 min): rename to preserve crash evidence
if [ -f "$LOG" ]; then
  LOG_MTIME=$(stat -c %Y "$LOG" 2>/dev/null || date -r "$LOG" +%s 2>/dev/null || echo 0)
  LOG_AGE=$(( NOW_EPOCH - LOG_MTIME ))

  if [ "$LOG_AGE" -ge "$STALE_THRESHOLD" ]; then
    # Stale log = crash evidence from a previous session
    OLD_SID=$(head -1 "$LOG" | sed -n 's/.*sid=\([^ ]*\).*/\1/p')
    [ -z "$OLD_SID" ] && OLD_SID="unknown"
    mv "$LOG" "$SESSIONS_DIR/active-changes-${OLD_SID}.log"
  fi
  # If fresh, just keep appending (handles /compact + concurrent sessions)
fi

# Write header if log doesn't exist (new session or was just renamed)
if [ ! -f "$LOG" ]; then
  echo "# SESSION cwd=$CWD sid=$SID started=$NOW" > "$LOG"
fi

# Compute relative path
REL_PATH="${FILE_PATH#$CWD/}"
# If stripping didn't work (path doesn't start with cwd), use as-is
if [ "$REL_PATH" = "$FILE_PATH" ]; then
  REL_PATH=$(realpath --relative-to="$CWD" "$FILE_PATH" 2>/dev/null || echo "$FILE_PATH")
fi

# Append change line
echo "$NOW $TOOL_NAME $REL_PATH" >> "$LOG"
