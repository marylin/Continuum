# Initialize Project

Initialize this project to work with the WhateverAI workflow conventions. Scan everything first, then set it all up.

## Step 1: Project Analysis (do NOT create anything yet)

Scan the project and detect:

1. **Stack**: Check package.json, requirements.txt, Cargo.toml, go.mod, pyproject.toml, Gemfile, etc. Identify language, framework, major dependencies.
2. **Dev commands**: Find how to run dev server, build, test, lint from package.json scripts, Makefile, docker-compose, etc.
3. **Database**: Check for ORM configs, .env files, docker-compose services, connection strings. Identify DB type and connection.
4. **Test framework**: Detect existing test setup (Jest, Vitest, Playwright, pytest, etc.) and where tests currently live.
5. **Existing structure**: Map current folder layout. Note what already exists that maps to the standard docs/ and tests/ structure.
6. **Root .md files**: List any markdown files in root besides README.md.
7. **Existing CLAUDE.md**: Check if one exists and what's in it.

Present findings in this exact format:

    Project: [detected name from package.json or folder name]
    Stack: [language + framework + major deps]
    Dev: [run command]
    Test: [test command]
    DB: [type + connection or "none detected"]
    Test framework: [detected or "none"]

    Existing structure issues:
    | Issue | File/Folder | Proposed Action |
    |-------|-------------|-----------------|
    | ... | ... | ... |

## Step 2: Confirm With Me

Show the analysis and ask:
- "Is this accurate? Anything to correct before I set up?"
- Flag anything ambiguous (multiple possible test commands, unclear DB setup, etc.)
- If co-located tests exist, ask: keep co-location or move to tests/?

Do NOT proceed until I confirm.

## Step 3: Execute Setup

Once confirmed:

**3a. Create project CLAUDE.md**

Overwrite if it only has old workflow rules. If it has project-specific rules, preserve them and update the template structure around them. Fill in detected values:

    # CLAUDE.md

    ## Project
    - **Name**: [detected]
    - **Stack**: [detected]
    - **Description**: [infer from README.md or package.json description, or "TODO: add description"]

    ## Dev
    - **Run**: [detected command]
    - **Test**: [detected command]
    - **DB**: [detected or "N/A"]

    ## Rules
    <!-- Project-specific only. Keep under 10 lines. -->

**3b. Create docs structure** (only folders that don't already exist)

    docs/01-Discovery/
    docs/02-Requirements/
    docs/03-Architecture/
    docs/04-Design/
    docs/05-Plans/
    docs/06-Development/
    docs/07-Testing/
    docs/08-Feedback/
    docs/09-Archive/

**3c. Create docs/06-Development/lessons.md** if missing, with content:

    # Lessons Learned

    <!-- Format: - [category] lesson in one line -->
    <!-- Updated automatically after corrections. Reviewed at session start. -->

**3d. Create test structure** (only if project has tests or test framework detected, only folders that don't exist)

    tests/unit/
    tests/integration/
    tests/e2e/
    tests/fixtures/

Skip if project uses co-location and I chose to keep it.

**3e. Relocate stray files**

- Move any root .md files (except README.md, CLAUDE.md) to appropriate docs/ folder
- Use `git mv` if inside a git repo to preserve history
- Move stray test files to correct tests/ subfolder

**3f. Commit**

    docs(setup): initialize project structure and CLAUDE.md

## Step 4: Verify and Report

Show compact summary in this exact format:

    ✅ Project initialized
       CLAUDE.md: created/updated with detected config
       Docs: [count] folders created
       Tests: [count] folders created (or "skipped — using co-location")
       Lessons: docs/06-Development/lessons.md created
       Moved: [count] files relocated (or "none needed")
       Commit: docs(setup): initialize project structure and CLAUDE.md

       Ready to use: /plan, /status, /resume, /test, /align

## Rules

- Never delete any file — move to docs/09-Archive/ if obsolete
- Never guess the stack — read actual config files
- If README.md has a description, use it for CLAUDE.md description. If not, put "TODO: add description"
- If project has no package.json/requirements.txt/etc, ask me about the stack
- If CLAUDE.md already exists with project-specific rules, PRESERVE those rules and only update the template structure around them
- If existing docs/ structure uses different naming, ask before overwriting
- Keep the project CLAUDE.md under 15 lines

Project: $ARGUMENTS
