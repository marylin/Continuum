#!/usr/bin/env bash
# gitignore-audit.sh — Ensure .env*, .claude/, docs/ are in .gitignore for all repos.
# Usage: gitignore-audit.sh [repos-root] [--dry-run]
set -euo pipefail
source "$HOME/.claude/config.sh"
ROOT="${1:-$REPOS_ROOT}"
DRY_RUN="${2:-}"
FIXED=0

audit_project() {
  local dir="$1"
  local name="$(basename "$dir")"
  local gitignore="$dir/.gitignore"
  local changed=false

  [[ -f "$gitignore" ]] || touch "$gitignore"

  for pattern in '.env*' '.claude/' 'docs/'; do
    if ! grep -qxF "$pattern" "$gitignore" 2>/dev/null; then
      if [[ "$DRY_RUN" == "--dry-run" ]]; then
        echo "  WOULD ADD '$pattern' to $name/.gitignore"
      else
        echo "$pattern" >> "$gitignore"
        echo "  Added '$pattern' to $name/.gitignore"
      fi
      changed=true
    fi
  done

  if [[ "$changed" == true ]]; then
    FIXED=$((FIXED + 1))
  fi
}

echo "Auditing .gitignore files under: $ROOT"

for d in "$ROOT"/*/; do
  [[ -d "$d/.git" ]] && audit_project "$d"
  for sub in "$d"*/; do
    [[ -d "$sub/.git" ]] && audit_project "$sub"
  done
done

echo "Done. Fixed $FIXED projects."
