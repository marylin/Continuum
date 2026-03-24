#!/usr/bin/env bash
# PostToolUse hook: track git commits to append-only log
# Trigger: matcher "Bash(git commit*)" — runs after Linear sync + journey accumulate
# Token cost: 0 (command hook, no LLM)

SESSIONS_DIR="$HOME/.claude/sessions"
LOG="$SESSIONS_DIR/active-changes.log"

# No log = no active session to track
[ ! -f "$LOG" ] && exit 0

# Find jq
JQ=$(command -v jq 2>/dev/null)
if [ -z "$JQ" ]; then
  JQ="$HOME/AppData/Local/Microsoft/WinGet/Packages/jqlang.jq_Microsoft.Winget.Source_8wekyb3d8bbwe/jq.exe"
fi
[ ! -x "$JQ" ] && exit 0

# Read stdin JSON
INPUT=$(cat)
CWD=$("$JQ" -r '.cwd // empty' <<< "$INPUT")
[ -z "$CWD" ] && exit 0

CWD="${CWD//\\//}"
NOW=$(date +%Y-%m-%dT%H:%M:%S%z)

# Get last commit info
COMMIT_INFO=$(git -C "$CWD" log -1 --format="%h %s" 2>/dev/null)
[ -z "$COMMIT_INFO" ] && exit 0

echo "$NOW COMMIT $COMMIT_INFO" >> "$LOG"

# Snapshot current dirty state
while IFS= read -r line; do
  [ -n "$line" ] && echo "$NOW GITSTATUS $line" >> "$LOG"
done < <(git -C "$CWD" status --porcelain 2>/dev/null)
