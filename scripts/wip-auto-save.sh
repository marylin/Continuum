#!/usr/bin/env bash
# wip-auto-save.sh — PostToolUse hook: auto-save uncommitted work every 10 edits.
set -euo pipefail

INPUT="$(cat)"
CWD="$(echo "$INPUT" | sed -n 's/.*"cwd" *: *"\([^"]*\)".*/\1/p')"
CWD="${CWD//\\//}"

if [[ -z "$CWD" ]]; then
  exit 0
fi

PROJECT_NAME="$(basename "$CWD")"
VAULT_DIR="$HOME/.claude/vaults/$PROJECT_NAME"

[[ -d "$VAULT_DIR" ]] || exit 0
git -C "$CWD" rev-parse --git-dir &>/dev/null || exit 0

COUNTER_FILE="$VAULT_DIR/.wip-counter"

COUNT=0
if [[ -f "$COUNTER_FILE" ]]; then
  COUNT="$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)"
fi
COUNT=$(( COUNT + 1 ))
echo "$COUNT" > "$COUNTER_FILE"

if (( COUNT % 10 != 0 )); then
  exit 0
fi

cd "$CWD"
DIRTY="$(git status --porcelain 2>/dev/null)"
if [[ -z "$DIRTY" ]]; then
  echo "0" > "$COUNTER_FILE"
  exit 0
fi

# Check if current branch has a commit within last 5 minutes
LAST_COMMIT_AGE="$(git log -1 --format=%cr 2>/dev/null || echo "unknown")"
if echo "$LAST_COMMIT_AGE" | grep -qE '^[0-4] minutes? ago$'; then
  exit 0
fi

TIMESTAMP="$(date +%Y%m%d-%H%M)"
WIP_BRANCH="wip/${PROJECT_NAME}-${TIMESTAMP}"
ORIGINAL_BRANCH="$(git branch --show-current 2>/dev/null || echo "HEAD")"

git stash push -m "wip-auto-save $TIMESTAMP" --quiet 2>/dev/null || exit 0
git stash branch "$WIP_BRANCH" &>/dev/null || {
  git stash pop --quiet 2>/dev/null
  exit 0
}
git checkout "$ORIGINAL_BRANCH" --quiet 2>/dev/null
git stash pop --quiet 2>/dev/null || true

echo "0" > "$COUNTER_FILE"
exit 0
