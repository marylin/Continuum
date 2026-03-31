#!/usr/bin/env bash
# vault-init.sh — Create a vault for a project from its existing files.
# Usage: vault-init.sh /path/to/project
set -euo pipefail

PROJECT_PATH="${1:?Usage: vault-init.sh /path/to/project}"
PROJECT_PATH="${PROJECT_PATH%/}"
PROJECT_NAME="$(basename "$PROJECT_PATH")"
VAULT_DIR="$HOME/.claude/vaults/$PROJECT_NAME"

if [[ ! -d "$PROJECT_PATH" ]]; then
  echo "ERROR: Project path does not exist: $PROJECT_PATH" >&2
  exit 1
fi

echo "Initializing vault for: $PROJECT_NAME"
mkdir -p "$VAULT_DIR"

# Copy .env files (prefer .env.develop, fall back to .env)
if [[ -f "$PROJECT_PATH/.env.develop" ]]; then
  cp -n "$PROJECT_PATH/.env.develop" "$VAULT_DIR/.env.develop" 2>/dev/null || true
  echo "  Copied .env.develop"
elif [[ -f "$PROJECT_PATH/.env" ]]; then
  cp -n "$PROJECT_PATH/.env" "$VAULT_DIR/.env" 2>/dev/null || true
  echo "  Copied .env"
else
  echo "  No .env file found (skipped)"
fi

# Copy .claude/ directory (exclude settings.local.json)
if [[ -d "$PROJECT_PATH/.claude" ]]; then
  mkdir -p "$VAULT_DIR/.claude"
  # Use cp -r since rsync is not available on Windows Git Bash
  # Copy files that don't already exist in vault
  find "$PROJECT_PATH/.claude" -type f ! -name 'settings.local.json' | while read -r src; do
    rel="${src#$PROJECT_PATH/.claude/}"
    dest="$VAULT_DIR/.claude/$rel"
    if [[ ! -f "$dest" ]]; then
      mkdir -p "$(dirname "$dest")"
      cp "$src" "$dest"
    fi
  done
  echo "  Copied .claude/"
else
  echo "  No .claude/ directory found (skipped)"
fi

# Copy docs/ directory
if [[ -d "$PROJECT_PATH/docs" ]]; then
  mkdir -p "$VAULT_DIR/docs"
  # Copy files that don't already exist in vault
  find "$PROJECT_PATH/docs" -type f | while read -r src; do
    rel="${src#$PROJECT_PATH/docs/}"
    dest="$VAULT_DIR/docs/$rel"
    if [[ ! -f "$dest" ]]; then
      mkdir -p "$(dirname "$dest")"
      cp "$src" "$dest"
    fi
  done
  echo "  Copied docs/"
else
  echo "  No docs/ directory found (skipped)"
fi

# Create CONTEXT.md template if it doesn't exist
if [[ ! -f "$VAULT_DIR/CONTEXT.md" ]]; then
  cat > "$VAULT_DIR/CONTEXT.md" << TEMPLATE
# Context — $PROJECT_NAME

## Current State
- Working on: (no prior session)
- Branch: unknown
- Blocked: none

## Recent Activity

## Key Files

## Decisions
TEMPLATE
  echo "  Created CONTEXT.md"
else
  echo "  CONTEXT.md already exists (skipped)"
fi

echo "Vault ready: $VAULT_DIR"
