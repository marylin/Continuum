#!/usr/bin/env bash
# update-context.sh — Stop hook: update vault CONTEXT.md from active-changes.log
# Must run BEFORE assemble-session-state.sh (which deletes the log).
# Exits 0 on all paths — hooks must never block session exit.
set -euo pipefail

LOG_FILE="$HOME/.claude/sessions/active-changes.log"

# Exit silently if no log exists (nothing to record)
[[ -f "$LOG_FILE" ]] || exit 0

# Extract project info from SESSION header
SESSION_LINE="$(grep '^# SESSION' "$LOG_FILE" | tail -1 || true)"
[[ -n "$SESSION_LINE" ]] || exit 0

CWD="$(echo "$SESSION_LINE" | sed 's/.*cwd=\([^ ]*\).*/\1/')"
CWD="${CWD//\\//}"  # normalize backslashes to forward slashes
PROJECT_NAME="$(basename "$CWD")"
VAULT_DIR="$HOME/.claude/vaults/$PROJECT_NAME"

# Auto-create vault for new projects (only if CWD is a git repo)
if [[ ! -d "$VAULT_DIR" ]]; then
  if git -C "$CWD" rev-parse --git-dir &>/dev/null; then
    mkdir -p "$VAULT_DIR"
  else
    exit 0
  fi
fi

CONTEXT_FILE="$VAULT_DIR/CONTEXT.md"
NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Extract current branch
BRANCH="unknown"
if git -C "$CWD" rev-parse --git-dir &>/dev/null; then
  BRANCH="$(git -C "$CWD" branch --show-current 2>/dev/null || echo "detached")"
  [[ -n "$BRANCH" ]] || BRANCH="detached"
fi

# Extract last STATE line or last COMMIT message for task description
TASK="(no task recorded)"
STATE_LINE="$(grep '^STATE:' "$LOG_FILE" | tail -1 || true)"
if [[ -n "$STATE_LINE" ]]; then
  TASK="${STATE_LINE#STATE: }"
else
  COMMIT_LINE="$(grep ' COMMIT ' "$LOG_FILE" | tail -1 || true)"
  if [[ -n "$COMMIT_LINE" ]]; then
    TASK="$(echo "$COMMIT_LINE" | sed 's/.*COMMIT [a-f0-9]* //')"
  fi
fi

# Count file changes and commits
# grep -c outputs "0" AND returns exit 1 on zero matches — capture separately
FILE_COUNT="$(grep -c ' \(Edit\|Write\) ' "$LOG_FILE" 2>/dev/null)" || FILE_COUNT=0
COMMIT_COUNT="$(grep -c ' COMMIT ' "$LOG_FILE" 2>/dev/null)" || COMMIT_COUNT=0

# Build activity summary line
ACTIVITY_LINE="- [$NOW cli] $TASK ($FILE_COUNT files, $COMMIT_COUNT commits, branch: $BRANCH)"

if [[ -f "$CONTEXT_FILE" ]]; then
  # --- Update existing CONTEXT.md ---

  # Update Current State fields
  sed -i "s|^- Working on:.*$|- Working on: $TASK|" "$CONTEXT_FILE"
  sed -i "s|^- Branch:.*$|- Branch: $BRANCH|" "$CONTEXT_FILE"

  # Append new activity entry after ## Recent Activity header.
  # sed 'a' on Git Bash can be unreliable, so use awk for the insert.
  awk -v line="$ACTIVITY_LINE" '
    /^## Recent Activity$/ { print; print line; next }
    { print }
  ' "$CONTEXT_FILE" > "$CONTEXT_FILE.tmp" && mv "$CONTEXT_FILE.tmp" "$CONTEXT_FILE"

  # Trim Recent Activity to last 20 entries (most recent at top).
  # Keeps the ## header, up to 20 activity lines, then everything after
  # the next ## heading.
  awk '
    /^## Recent Activity$/ { in_ra=1; print; next }
    in_ra && /^## / { in_ra=0; flush_remaining(); print; next }
    in_ra && /^- / { ra[++n]=$0; next }
    in_ra && /^[[:space:]]*$/ { blanks++; next }
    in_ra { next }
    { print }
    END { if(in_ra) flush_remaining() }
    function flush_remaining() {
      start = (n > 20) ? n - 19 : 1
      for(i=1; i<=n && i<=20; i++) print ra[i]
      print ""
    }
  ' "$CONTEXT_FILE" > "$CONTEXT_FILE.tmp" && mv "$CONTEXT_FILE.tmp" "$CONTEXT_FILE"
else
  # --- Create fresh CONTEXT.md ---
  cat > "$CONTEXT_FILE" << TEMPLATE
# Context — $PROJECT_NAME

## Current State
- Working on: $TASK
- Branch: $BRANCH
- Blocked: none

## Recent Activity
$ACTIVITY_LINE

## Key Files

## Decisions
TEMPLATE
fi

# --- Sync project files → vault (project is source of truth during a session) ---

# Sync docs/ → vault
if [[ -d "$CWD/docs" ]]; then
  mkdir -p "$VAULT_DIR/docs"
  cp -ru "$CWD/docs/." "$VAULT_DIR/docs/" 2>/dev/null || true
fi

# Sync .env* files → vault
for envfile in "$CWD"/.env*; do
  [[ -f "$envfile" ]] || continue
  cp -u "$envfile" "$VAULT_DIR/$(basename "$envfile")" 2>/dev/null || true
done

exit 0
