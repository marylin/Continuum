#!/usr/bin/env bash
# vault-init-all.sh — Run vault-init on all git repos under REPOS_ROOT.
# Usage: vault-init-all.sh [repos-root]
set -euo pipefail
source "$HOME/.claude/config.sh"
ROOT="${1:-$REPOS_ROOT}"

echo "Scanning for git repos under: $ROOT"
COUNT=0

for d in "$ROOT"/*/; do
  if [[ -d "$d/.git" ]]; then
    bash "$(dirname "$0")/vault-init.sh" "$d"
    COUNT=$((COUNT + 1))
  fi
  for sub in "$d"*/; do
    if [[ -d "$sub/.git" ]]; then
      bash "$(dirname "$0")/vault-init.sh" "$sub"
      COUNT=$((COUNT + 1))
    fi
  done
done

echo "Done. Initialized $COUNT vaults."
