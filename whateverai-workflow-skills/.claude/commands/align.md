# Align Project

Audit this project and align it with WhateverAI workflow standards.

## Step 1: Scan (no changes yet)

Report as a compact table:

| Issue | File/Folder | Proposed Action |
|-------|-------------|-----------------|

Check for: stray root .md files, missing docs/ folders, missing lessons.md, duplicate folders, CLAUDE.md with embedded workflow rules, stray test files.

Flag ambiguities: co-located tests (keep or move?), docs that could go in multiple folders.

## Step 2: Approve

Show the table. Wait for approval before executing.

## Step 3: Execute

1. Create needed folders: `docs/{01-Discovery,...,09-Archive}` and `tests/{unit,integration,e2e,fixtures}`
2. Create `docs/06-Development/lessons.md` if missing
3. `git mv` for all moves (preserve history)
4. Update import paths and markdown links
5. Replace CLAUDE.md workflow rules with minimal template (preserve project-specific info)
6. Commit: `refactor(structure): align project with standard conventions`

## Step 4: Verify

- No root .md except README.md + CLAUDE.md
- lessons.md exists, no duplicate folders
- Show final tree (2 levels deep)

Rules: Never delete -- archive to docs/09-Archive/. Ask before forcing template on close-enough structure.

Project: $ARGUMENTS
