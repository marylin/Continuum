# Align Project

Audit this project and align it with WhateverAI workflow standards.

## Step 1: Scan & Report (do NOT change anything yet)

Check and report as a compact table:

| Issue | File/Folder | Proposed Action |
|-------|-------------|-----------------|
| Root .md | ./notes.md | → docs/01-Discovery/ |
| Missing folder | docs/05-Plans/ | CREATE |
| Missing file | docs/06-Development/lessons.md | CREATE (empty with header) |
| Duplicate | ./documentation/ + ./docs/ | MERGE → docs/ |
| Old CLAUDE.md | ./CLAUDE.md has workflow rules | REPLACE with minimal template |
| Stray tests | ./test-login.js | → tests/unit/auth/ |

Also flag:
- Co-located test files (ask me: keep co-location or move?)
- Ambiguous docs (ask me: which folder?)

## Step 2: Wait for Approval

Show the table. Ask about ambiguous cases. Do NOT execute until I approve.

## Step 3: Execute

1. Create only needed folders from: docs/{01-Discovery,02-Requirements,03-Architecture,04-Design,05-Plans,06-Development,07-Testing,08-Feedback,09-Archive} and tests/{unit,integration,e2e,fixtures}
2. Create docs/06-Development/lessons.md if missing (header: `# Lessons Learned`)
3. Use `git mv` for all moves (preserve history)
4. Update import paths and markdown links for moved files
5. If CLAUDE.md has workflow rules, replace with minimal template — preserve project-specific info
6. Do NOT rewrite existing plan/progress file contents — just move them
7. Commit: `refactor(structure): align project with standard conventions`

## Step 4: Verify

- No root .md except README.md + CLAUDE.md
- No duplicate folders
- lessons.md exists in docs/06-Development/
- Run test suite — report results in compact format
- Show final tree (2 levels deep)

Rules: Never delete — archive to docs/09-Archive/. If existing structure is close, ask before forcing template.

Project: $ARGUMENTS
