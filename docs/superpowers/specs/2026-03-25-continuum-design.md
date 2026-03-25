# Continuum — Design Spec

A project lifecycle system for Claude Code. 7 skills that help Claude remember what you were doing, pick up where you left off, and get smarter over time.

---

## Plugin Identity

- **Name:** continuum
- **Repo:** `github:marylin/continuum`
- **Install:** `/install github:marylin/continuum`
- **Version:** 2.0.0 (breaking change from whateverai-commands v1.x)
- **Author:** Marylin Alarcon
- **License:** MIT

---

## The Loop

```
init → align → plan → resume ⇄ checkpoint
                 ↑        ↓         ↓
              reflect   recover (crash)
                 ↑         ↓
                 └─────────┘
```

Every skill feeds the next. Plans create progress files. Checkpoints save cognitive state. Recover reads checkpoints. Reflect extracts lessons. Lessons inform the next plan.

---

## Skills (7)

### 1. init

**Description:** `"Bootstrap a project with structured docs, CLAUDE.md, and lifecycle directory. Use when starting a new project, onboarding to an existing repo, or when a project has no CLAUDE.md or organized structure."`

**What it does:**
1. Scan project: detect stack, commands, DB, test framework, existing structure
2. Present findings, ask for confirmation
3. Create `.lifecycle/` directory (ask user: git-tracked or gitignored)
4. Generate CLAUDE.md following Anthropic best practices:
   - Commands section (detected from package.json / pyproject.toml / etc.)
   - Code style section (commented scaffolding for user to fill)
   - Architecture decisions section (commented scaffolding)
   - Gotchas section (commented scaffolding)
   - Reference to `.lifecycle/lessons/` via `@` import
   - Under 200 lines — only things Claude can't infer from code
5. For medium/large projects: scaffold `.claude/rules/` with path-scoped rule files based on detected project domains (e.g., api/, db/, tests/)
6. Commit: `docs(setup): initialize project structure and CLAUDE.md`
7. Verify and show summary

**Reads:** project config files, existing structure
**Writes:** `.lifecycle/`, CLAUDE.md, optionally `.claude/rules/`, `.gitignore`

**CLAUDE.md template:**
```markdown
# Project

[One sentence — only if README.md doesn't exist or is unclear]

# Commands

- Dev: `[detected]`
- Build: `[detected]`
- Test: `[detected]`
- Lint: `[detected]`
- Single test: `[detected]`

# Code style

<!-- Only rules that DIFFER from language defaults. Delete this comment and add rules, or delete the section. -->

# Architecture decisions

<!-- Only non-obvious choices Claude would get wrong. Delete this comment and add decisions, or delete the section. -->

# Gotchas

<!-- Things that will break Claude if not warned. Delete this comment and add gotchas, or delete the section. -->

# References

See @.lifecycle/lessons/ for patterns learned from past work
```

**Project size handling:**
- Small (<20 source files): everything in CLAUDE.md
- Medium (20-100 files): CLAUDE.md + suggest 1-2 `.claude/rules/` files
- Large (100+ files): CLAUDE.md + scaffold `.claude/rules/` with path-scoped files

**Rules file format:**
```markdown
# .claude/rules/api-conventions.md
---
paths:
  - src/api/**
  - src/routes/**
---
- All endpoints return { data, error, meta } envelope
- Use zod for request validation
```

---

### 2. align

**Description:** `"Audit project structure, docs health, and lifecycle compliance. Use when a project feels disorganized, after major refactors, before onboarding a contributor, or periodically as a health check."`

**What it does:**
1. Scan and audit (no changes):
   - `.lifecycle/` exists and has expected subdirectories
   - CLAUDE.md exists and is under 200 lines
   - CLAUDE.md doesn't contain things Claude can infer from code
   - `.claude/rules/` files have `paths:` frontmatter (not loading every session). Flag `path:` (singular) as common misconfiguration.
   - Stale rules referencing paths that don't exist
   - Plans in `.lifecycle/plans/` that should be archived (all tasks done)
   - Lessons freshness (any `.lifecycle/lessons/` files updated in last 30 days?)
   - Test directories mirror source directories
2. Present health score (0-10) with breakdown table
3. Wait for approval
4. Execute fixes (git mv for moves, preserve history)
5. Verify and show final state

**Reads:** `.lifecycle/`, CLAUDE.md, `.claude/rules/`, project structure
**Writes:** fixes to flagged issues

---

### 3. plan

**Description:** `"Create a structured implementation plan with sized tasks and acceptance criteria. Use when starting any non-trivial feature (3+ steps), when a task feels ambiguous, or when you need to break down a large request before coding."`

**What it does:**
1. Check `.lifecycle/lessons/[relevant topics].md` for applicable lessons
2. Analyze the request
3. Create `.lifecycle/plans/[name]-plan.md`:
   ```markdown
   # [Feature Name] Plan

   ## Summary
   [2-3 sentences. What and why.]

   ## Tasks
   1. [S] Task — acceptance criteria in one line
   2. [M] Task — criteria
   3. [L] Task — criteria

   ## Dependencies
   [Only if tasks depend on each other. Skip if none.]

   ## Open Questions
   [Anything ambiguous. Skip if clear.]
   ```
4. Present summary and questions. Wait for approval.
5. On approval, create `.lifecycle/plans/[name]-progress.md`:
   ```markdown
   # [Feature Name] Progress

   [ ] Task 1
   [ ] Task 2
   [ ] Task 3
   ```
6. Begin executing the first task immediately (same session). Continue without asking between tasks.
7. Update progress as tasks complete
8. If session ends before all tasks are done, the user runs `/resume` in the next session to continue

**Reads:** `.lifecycle/lessons/[relevant].md`
**Writes:** `.lifecycle/plans/[name]-plan.md`, `.lifecycle/plans/[name]-progress.md`

**Rules:**
- One line per task, no paragraphs
- Complexity: S = <30min, M = 1-3hrs, L = 3hrs+
- Reference external docs instead of inlining
- If something goes sideways mid-execution: STOP and re-plan

---

### 4. resume

**Description:** `"Resume in-progress work from where you left off. Use when returning to a feature after a break, starting a new session on ongoing work, or after /compact. Shows progress and picks up the next task."`

**What it does:**
1. Find active progress files in `.lifecycle/plans/` (also check `docs/05-Plans/` as v1.x fallback)
2. If multiple progress files found: list them with last-modified timestamps and ask user to select
3. If no progress files: suggest `/recover` for crashed sessions or `/plan` for new work
3. Show compact status:
   ```
   Feature: auth-system | Progress: 4/8 tasks
   Done: Task 1, Task 2, Task 3, Task 4
   Next: Task 5 — add session middleware
   ```
4. Check for checkpoint files in `.lifecycle/checkpoints/` — if found, show cognitive state:
   ```
   Last checkpoint (2h ago):
   Context: Implementing JWT validation, chose RS256 over HS256 for key rotation
   Next steps: Wire up middleware, then integration tests
   Gotcha: Token refresh endpoint needs rate limiting
   ```
5. Read `.lifecycle/lessons/[relevant topics].md` for applicable lessons
6. Read plan file ONLY for the next incomplete task's details
7. Continue from next `[ ]` or `[~]` task
8. Update progress as tasks complete — one line per task, no prose
9. If context limit approaching: run `/checkpoint`, commit, `/compact`, resume
10. If something goes sideways: STOP and re-plan

**Reads:** `.lifecycle/plans/`, `.lifecycle/checkpoints/`, `.lifecycle/lessons/`
**Writes:** progress file updates

---

### 5. checkpoint

**Description:** `"Save a cognitive snapshot — what you're doing, why, decisions made, and what's next. Use before ending a session, before /compact, when context is getting long, or anytime you want to preserve reasoning for a future session."`

**What it does:**
1. Identify current feature from active progress file. If no active progress file, ask: "No active plan found. What are you working on?" and use the answer as the feature name
2. Write `.lifecycle/checkpoints/[feature]-checkpoint.md`:
   ```markdown
   # Checkpoint: [feature]
   **Saved:** [ISO timestamp]
   **Task:** [current task from progress file]
   **Progress:** [N/M tasks complete]

   ## Context
   [What I'm doing and why — 2-3 sentences max]

   ## Decisions Made
   - [Decision]: [reasoning] — one line each

   ## What's Next
   1. [Concrete next step]
   2. [Step after that]

   ## Gotchas
   - [Things the next session should watch for]
   ```
3. Overwrites previous checkpoint for the same feature (only latest matters)
4. Confirm: `Checkpoint saved for [feature]. Resume with /resume or recover with /recover.`

**Reads:** active progress file, current work context
**Writes:** `.lifecycle/checkpoints/[feature]-checkpoint.md`

**Design notes:**
- Lightweight — should take <5 seconds and <200 tokens to invoke
- No git commit on checkpoint (it's a working state, not a milestone)
- Other skills suggest checkpointing: `resume` suggests it when context is long, `plan` suggests it between large tasks

---

### 6. recover

**Description:** `"Recover work from a crashed or interrupted session. Use when Claude crashed mid-task, after an unexpected exit, when you see 'stale sessions detected', or when you lost context and need to figure out what was happening."`

**What it does:**

**Phase 0: Check checkpoints**
1. Look for checkpoint files in `.lifecycle/checkpoints/`
2. If found, present cognitive state alongside recovery data (this is the key differentiator — not just "these files changed" but "you were doing X because Y")

**Phase 1: Check crash logs (active-changes.log)**
3. Check `~/.claude/sessions/active-changes.log` and rotated logs
4. If no logs found, note: "No session hooks detected. Crash log recovery requires hooks that write to ~/.claude/sessions/active-changes.log. See continuum README for setup." Then skip to Phase 2.
5. Parse SESSION headers for cwd, sid, started
6. Extract file paths (EDIT/WRITE) and COMMIT history
7. Extract last STATE line
8. Determine each file's state via git:
   - `~` still modified
   - `+` committed
   - `x` lost
9. Present:
   ```
   Crashed session recovered:
   Feature: [name] | Task: [from checkpoint or STATE]

   Checkpoint (if available):
   Context: [what was happening]
   Next: [what was planned next]

   Files (N edits across M files):
     ~ src/api/routes.ts — still modified
     + src/middleware/auth.ts — committed (abc1234)
     x tests/auth.test.ts — lost

   Resume from here, start fresh with this context, or discard?
   ```
10. Resume → continue, delete logs. Fresh → present as context. Discard → delete logs.

**Phase 2: Legacy session JSON files**
11. Scan `~/.claude/sessions/session-*.json` for active sessions
12. Same recovery flow as Phase 1

**Edge cases:**
- No checkpoints, no logs, no JSONs: "No crashed sessions. Did you mean /resume?"
- Sessions older than 7 days: flag as stale but allow recovery
- Not a git repo: skip file status analysis

**Reads:** `.lifecycle/checkpoints/`, crash logs, session JSONs, git state
**Writes:** recovery summary, log cleanup

---

### 7. reflect

**Description:** `"Extract lessons from completed work and archive the plan. Use after finishing a feature, when all tasks are done, or when you want to capture what you learned before moving on."`

**What it does:**
1. Find the completed plan (all tasks `[x]` in progress file, or match `$ARGUMENTS`). Also check `docs/05-Plans/` as v1.x fallback.
2. If no completed plans: "No completed plans found. Finish your tasks first."
3. Read the plan and progress files
4. Analyze git history for the feature's commits
5. Identify patterns:
   - **Corrections** — tasks re-planned or re-done (evidence: [!] blocked states in progress, re-planning commits, or tasks marked done then reopened)
   - **Surprises** — S tasks that took M/L effort, or vice versa
   - **Discoveries** — new tools, patterns, or gotchas encountered
   - **What worked** — approaches worth repeating
6. Present findings and proposed lessons. Wait for approval.
7. Append approved lessons to `.lifecycle/lessons/[topic].md`:
   ```markdown
   - [YYYY-MM-DD] Lesson in one line
   ```
   Create new topic files as needed. Don't duplicate existing lessons.
8. Archive: move plan + progress + checkpoint to `.lifecycle/archive/`
9. Commit: `docs(reflect): archive [feature] with [N] new lessons`
10. Summary:
    ```
    Reflected on: [feature]
    Lessons added: 3 (testing: 1, architecture: 2)
    Archived: plan + progress + checkpoint
    ```

**Reads:** `.lifecycle/plans/`, `.lifecycle/checkpoints/`, git log, `.lifecycle/lessons/`
**Writes:** `.lifecycle/lessons/[topic].md`, moves files to `.lifecycle/archive/`

**Topic detection:**
- Infer from plan content, file paths touched, and git diff domains
- Common topics: testing, architecture, performance, tooling, database, api, frontend, deployment
- If unsure, use `general.md`

---

## Directory Structure

### What ships (git-tracked):
```
continuum/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── init/SKILL.md
│   ├── align/SKILL.md
│   ├── plan/SKILL.md
│   ├── resume/SKILL.md
│   ├── checkpoint/SKILL.md
│   ├── recover/SKILL.md
│   └── reflect/SKILL.md
├── scripts/
│   └── validate.sh
├── .github/
│   └── workflows/
│       └── validate.yml
├── README.md
├── CHANGELOG.md
├── LICENSE
├── .gitignore
└── .gitattributes
```

### What exists locally (gitignored):
```
docs/                             ← gitignored
├── 09-Archive/
│   ├── do/SKILL.md              ← future standalone project
│   ├── catalog/SKILL.md         ← future standalone project
│   └── v1-dev-skills/           ← archived originals
└── promo-content-do-catalog.md
```

### What continuum creates in user projects:
```
project/
├── CLAUDE.md                     ← <200 lines, always loaded
├── .claude/
│   └── rules/                    ← path-scoped, on demand (medium/large projects)
│       ├── api-conventions.md
│       ├── database.md
│       └── testing.md
└── .lifecycle/                   ← tracked or gitignored (user chooses)
    ├── plans/                    ← active plans + progress files
    ├── checkpoints/              ← cognitive snapshots
    ├── lessons/                  ← topic-based learned patterns
    │   ├── testing.md
    │   ├── architecture.md
    │   └── [topic].md
    └── archive/                  ← completed plans + checkpoints
```

**Progressive disclosure (3 tiers):**
1. CLAUDE.md — every session, critical rules only
2. `.claude/rules/` — on demand, scoped to file paths
3. `.lifecycle/lessons/` — on demand, read by skills when relevant

---

## Validation Script

`scripts/validate.sh` — 4 checks:

1. **SKILL.md frontmatter** — every `skills/*/SKILL.md` has valid `name`, `description`; name matches directory name
2. **Skill count** — number of `skills/*/SKILL.md` files matches count in `plugin.json` description
3. **Version format** — `plugin.json` version is valid semver
4. **No stale references** — greps non-archived markdown for: "whateverai", "dev-skills", "workflow-skills", "plan-linear", "18 commands", "17 commands". Excludes CHANGELOG.md and migration docs from the check (they legitimately reference removed features)

**CI:** `.github/workflows/validate.yml`
- Push to `master`, PRs targeting `master`
- Runs `scripts/validate.sh`
- Replaces `paperclip-ci-notify.yml`

---

## README

High-level, scannable in <30 seconds. Structure:

1. **Name + one-liner:** Continuum — your Claude Code sessions remember, recover, and learn.
2. **The problem (2 sentences):** Claude Code sessions are stateless. When you crash, switch tasks, or come back tomorrow, all context is gone.
3. **What continuum does (the loop visual):** 7 skills that give your sessions memory.
4. **Install command:** one line
5. **Skills table:** 7 rows, name + one-liner each
6. **Quick start:** `init` your project, `plan` a feature, work, `checkpoint` before breaks, `reflect` when done.

No walls of text. No feature matrices. No "getting started guide." If they need more, the skill descriptions tell them everything.

---

## Migration from v1.x

For existing users of whateverai-commands:
- Plans in `docs/05-Plans/` continue to work — `resume` and `recover` check both `.lifecycle/plans/` and `docs/05-Plans/` as fallback
- `lessons.md` at `docs/06-Development/lessons.md` is read as fallback — `reflect` migrates entries to `.lifecycle/lessons/` on first run
- Linear sync references silently ignored
- Dev skills (`/build`, `/test`, etc.) no longer available — use Claude's built-in capabilities

---

## Breaking Changes Summary

| v1.x | v2.0 (continuum) |
|------|-------------------|
| 2 plugin packs, 17 skills | 1 plugin, 7 skills |
| `docs/05-Plans/` | `.lifecycle/plans/` |
| `docs/06-Development/lessons.md` | `.lifecycle/lessons/[topic].md` |
| `docs/09-Archive/` | `.lifecycle/archive/` |
| `.claude/commands/*.md` (legacy) | `skills/*/SKILL.md` only |
| Linear sync built-in | Removed |
| WhateverAI branding | Continuum (by Marylin Alarcon) |
