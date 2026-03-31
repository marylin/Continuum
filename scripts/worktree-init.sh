#!/usr/bin/env bash
# worktree-init.sh — Copy vault files into a worktree or project directory.
# Usage: worktree-init.sh /path/to/target [project-name]
# If project-name is omitted, derives from target path basename.
set -euo pipefail

TARGET_DIR="${1:?Usage: worktree-init.sh /path/to/target [project-name]}"
TARGET_DIR="${TARGET_DIR%/}"
PROJECT_NAME="${2:-$(basename "$TARGET_DIR")}"

# Strip agent/worktree suffixes to find the base project name
BASE_NAME="$PROJECT_NAME"
for vault in "$HOME/.claude/vaults"/*/; do
  VAULT_NAME="$(basename "$vault")"
  if [[ "$PROJECT_NAME" == "$VAULT_NAME"* ]]; then
    BASE_NAME="$VAULT_NAME"
    break
  fi
done

VAULT_DIR="$HOME/.claude/vaults/$BASE_NAME"

if [[ ! -d "$VAULT_DIR" ]]; then
  echo "No vault found for: $BASE_NAME (tried $VAULT_DIR)" >&2
  exit 0
fi

echo "Copying vault files for $BASE_NAME → $TARGET_DIR"

# Copy .env files
for envfile in "$VAULT_DIR"/.env*; do
  [[ -f "$envfile" ]] || continue
  DEST="$TARGET_DIR/$(basename "$envfile")"
  if [[ ! -f "$DEST" ]]; then
    cp "$envfile" "$DEST"
    echo "  Copied $(basename "$envfile")"
  fi
done

# Copy .claude/ directory (no rsync on Windows Git Bash — use find+cp)
if [[ -d "$VAULT_DIR/.claude" ]]; then
  mkdir -p "$TARGET_DIR/.claude"
  find "$VAULT_DIR/.claude" -type f | while read -r src; do
    rel="${src#$VAULT_DIR/.claude/}"
    dest="$TARGET_DIR/.claude/$rel"
    if [[ ! -f "$dest" ]]; then
      mkdir -p "$(dirname "$dest")"
      cp "$src" "$dest"
    fi
  done
  echo "  Copied .claude/"
fi

# Copy docs/ directory
if [[ -d "$VAULT_DIR/docs" ]]; then
  mkdir -p "$TARGET_DIR/docs"
  find "$VAULT_DIR/docs" -type f | while read -r src; do
    rel="${src#$VAULT_DIR/docs/}"
    dest="$TARGET_DIR/docs/$rel"
    if [[ ! -f "$dest" ]]; then
      mkdir -p "$(dirname "$dest")"
      cp "$src" "$dest"
    fi
  done
  echo "  Copied docs/"
fi

# Never copy CONTEXT.md into the repo — it stays vault-only
echo "Done."
