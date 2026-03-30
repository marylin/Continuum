#!/usr/bin/env bash
# read-context.sh — SessionStart hook: read CONTEXT.md, show resume prompt if recent
set -euo pipefail

# Read CWD from stdin JSON (SessionStart provides it)
INPUT="$(cat)"
CWD="$(echo "$INPUT" | sed -n 's/.*"cwd" *: *"\([^"]*\)".*/\1/p')"
CWD="${CWD//\\//}"

if [[ -z "$CWD" ]]; then
  CWD="$(pwd)"
  CWD="${CWD//\\//}"
fi

PROJECT_NAME="$(basename "$CWD")"
VAULT_DIR="$HOME/.claude/vaults/$PROJECT_NAME"
CONTEXT_FILE="$VAULT_DIR/CONTEXT.md"

# --- Sync vault → project (vault/Obsidian is source of truth) ---
if [[ -d "$VAULT_DIR" ]]; then
  # Sync docs/ from vault → project (cp -u: only if vault file is newer or missing in project)
  if [[ -d "$VAULT_DIR/docs" ]]; then
    mkdir -p "$CWD/docs"
    cp -ru "$VAULT_DIR/docs/." "$CWD/docs/" 2>/dev/null || true
  fi

  # Sync .env* from vault → project
  for envfile in "$VAULT_DIR"/.env*; do
    [[ -f "$envfile" ]] || continue
    cp -u "$envfile" "$CWD/$(basename "$envfile")" 2>/dev/null || true
  done
fi

[[ -f "$CONTEXT_FILE" ]] || exit 0

# Extract most recent activity timestamp (first line after ## Recent Activity that starts with "- [")
LAST_ACTIVITY="$(grep '^\- \[' "$CONTEXT_FILE" | head -1 | sed 's/^- \[\([^ ]*\).*/\1/')"

if [[ -z "$LAST_ACTIVITY" ]]; then
  exit 0
fi

NOW_EPOCH="$(date -u +%s)"
LAST_EPOCH="$(date -u -d "$LAST_ACTIVITY" +%s 2>/dev/null || echo 0)"

if [[ "$LAST_EPOCH" -eq 0 ]]; then
  exit 0
fi

AGE_SECONDS=$(( NOW_EPOCH - LAST_EPOCH ))
AGE_MINUTES=$(( AGE_SECONDS / 60 ))
TWO_HOURS=7200

TASK="$(grep '^- Working on:' "$CONTEXT_FILE" | head -1 | sed 's/^- Working on: //')"
BRANCH="$(grep '^- Branch:' "$CONTEXT_FILE" | head -1 | sed 's/^- Branch: //')"
BLOCKED="$(grep '^- Blocked:' "$CONTEXT_FILE" | head -1 | sed 's/^- Blocked: //')"

# Check for WIP branches
WIP_BRANCHES=""
if git -C "$CWD" rev-parse --git-dir &>/dev/null; then
  WIP_BRANCHES="$(git -C "$CWD" branch --list 'wip/*' 2>/dev/null | tr -d ' *' | head -3)"
fi

if [[ "$AGE_SECONDS" -lt "$TWO_HOURS" ]]; then
  PROMPT="Stale sessions detected:"
  PROMPT="$PROMPT\n  $PROJECT_NAME — \"$TASK\" on $BRANCH (${AGE_MINUTES}m ago)"

  if [[ -n "$WIP_BRANCHES" ]]; then
    PROMPT="$PROMPT\n  WIP branches: $(echo "$WIP_BRANCHES" | tr '\n' ', ' | sed 's/,$//')"
  fi

  if [[ "$BLOCKED" != "none" && -n "$BLOCKED" ]]; then
    PROMPT="$PROMPT\n  Blocked: $BLOCKED"
  fi

  PROMPT="$PROMPT\nRun /recover to resume or discard."
  echo -e "$PROMPT"
fi

exit 0
