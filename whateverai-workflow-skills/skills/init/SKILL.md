---
name: init
description: Initialize a project with WhateverAI workflow structure — CLAUDE.md, docs/, tests/, lessons.md
argument-hint: [project path]
---

# Initialize Project

Initialize this project to work with WhateverAI workflow conventions.

## Step 1: Scan (no changes yet)

Detect from config files:
1. **Stack**: package.json, pyproject.toml, Cargo.toml, go.mod, etc.
2. **Dev commands**: dev server, build, test, lint from scripts/Makefile/docker-compose
3. **Database**: ORM configs, .env, docker-compose services
4. **Test framework**: Jest, Vitest, Playwright, pytest, etc. and where tests live
5. **Existing structure**: current folder layout vs standard docs/tests structure
6. **Root .md files**: any besides README.md
7. **Existing CLAUDE.md**: contents if present

Present:
```
Project: [name]  Stack: [detected]  Dev: [cmd]  Test: [cmd]  DB: [type or "none"]

Structure issues:
| Issue | File/Folder | Proposed Action |
```

## Step 2: Confirm

Show analysis. Ask: "Is this accurate?" Flag ambiguities. Wait for approval.

## Step 3: Execute

**3a. Create CLAUDE.md** (preserve existing project-specific rules):
```
# CLAUDE.md
## Project
- **Name**: [detected]
- **Stack**: [detected]
- **Description**: [from README or "TODO"]

## Dev
- **Run**: [cmd]  **Test**: [cmd]  **DB**: [detected or "N/A"]

## Rules
<!-- Project-specific only. Under 10 lines. -->
```

**3b. Create docs structure** (skip existing):
```
docs/{01-Discovery,02-Requirements,03-Architecture,04-Design,05-Plans,06-Development,07-Testing,08-Feedback,09-Archive}/
```

**3c. Create `docs/06-Development/lessons.md`** if missing:
```
# Lessons Learned
<!-- Format: - [category] lesson in one line -->
```

**3d. Create test structure** (only if tests detected, skip existing):
```
tests/{unit,integration,e2e,fixtures}/
```

**3e. Relocate stray files**: `git mv` root .md (except README/CLAUDE) to appropriate docs/ folder. Move stray tests to tests/.

**3f. Commit**: `docs(setup): initialize project structure and CLAUDE.md`

## Step 4: Verify

```
✅ Project initialized
   CLAUDE.md: created/updated
   Docs: [N] folders  Tests: [N] folders  Moved: [N] files
   Commit: docs(setup): initialize project structure and CLAUDE.md
   Ready: /plan, /status, /resume, /test, /align
```

Rules: Never delete (archive to 09-Archive/). Never guess stack. Preserve existing project-specific CLAUDE.md rules. Keep CLAUDE.md under 15 lines.

Project: $ARGUMENTS
