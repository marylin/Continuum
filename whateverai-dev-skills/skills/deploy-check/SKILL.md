---
name: deploy-check
description: Run build, lint, types, tests, and git state checks before deploying
---

# Pre-Deploy Checklist

Run all checks before deploying. Detect ecosystem from config files.

| Check | What |
|-------|------|
| Build | Run build, must pass |
| Lint | Run linter if configured |
| Types | Run type checker if applicable |
| Tests | Run full test suite |
| Secrets | No `.env` or credentials in git |
| Lockfile | Lockfile consistent with manifest |
| Git | Working directory clean, all committed |

Report: PASS/FAIL per check, details on failures, overall deploy verdict.
