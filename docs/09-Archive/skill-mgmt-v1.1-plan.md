# Skill Management v1.1 — Roadmap Plan

## Overview

Enhance the skill management trio (`/do`, `/catalog`, `/recover`) with usage tracking, smarter routing, and better recovery UX. Optionally package them as a standalone plugin pack.

## 1. `/do` — Smart Routing with Usage Awareness

**Current state:** Keyword matching against `skills-reference.md` — name, description, category context. No memory of what the user actually uses.

**Goal:** Weight frequently-used skills higher so the most relevant match surfaces faster.

### Tasks

1. [S] **Track invocations** — When `/do` routes to a skill successfully, append a line to `~/.claude/skill-usage.json`:
   ```json
   { "skill": "/qa", "timestamp": "2026-03-19T14:00:00Z", "source": "do-router" }
   ```
   - Acceptance: after `/do` confirms and invokes a skill, the usage file is updated
   - Keep it append-only, one JSON object per line (JSONL) for simplicity

2. [S] **Read usage data during matching** — On step 6 of `/do`, load `skill-usage.json` and compute a frequency score per skill (invocations in last 30 days). Add as a fourth scoring signal:
   - Invoked 5+ times in 30 days → high boost
   - Invoked 1-4 times → medium boost
   - Never invoked → no boost
   - Acceptance: a skill used 10 times this month ranks above an equally-keyworded skill used 0 times

3. [S] **Show usage hint in output** — When presenting matches, append usage context:
   ```
   Best match: QA (gstack) — used 12 times this month
   ```
   - Acceptance: usage count appears in match output; "never used" omitted (clean output)

### Design decisions
- JSONL over SQLite: simpler, grep-able, no deps
- 30-day rolling window: old data decays naturally without explicit cleanup
- Source field (`do-router`) allows future tracking from other entry points (direct `/skill` invocation, hooks, etc.)
- File location `~/.claude/` keeps it global across projects

---

## 2. `/catalog` — Usage Metadata

**Current state:** Generates a static markdown table. No indication of which skills are actually used.

**Goal:** Show install counts (plugin source) and last-used timestamps so the catalog is actionable.

### Tasks

1. [S] **Read usage data** — On catalog generation, load `~/.claude/skill-usage.json` and compute per-skill: total invocations, last used date
   - Acceptance: usage data is available during catalog generation

2. [M] **Add columns to catalog table** — Extend the table format:
   ```
   | Skill | Command | Description | Source | Last Used | Uses (30d) |
   ```
   - `Last Used`: relative date ("3d ago", "2w ago", "never")
   - `Uses (30d)`: integer count
   - Acceptance: new columns appear in `skills-reference.md`

3. [S] **Sort option** — Add a secondary sort within categories: most-used first (alphabetical as tiebreaker). Keep alphabetical as default, add `## Most Used` section at top with top 10 across all categories.
   - Acceptance: top-10 section appears above category tables

### Design decisions
- "Install counts" doesn't apply to Claude Code skills (they're files, not npm packages) — reinterpret as "invocation count" which is more useful
- Relative dates keep the catalog scannable without mental math
- Top-10 section gives a quick-glance "what do I actually use?" answer

---

## 3. `/recover` — Diff View

**Current state:** Shows session state summary (skill, checklist, last actions). User must mentally reconstruct what was lost.

**Goal:** Show a diff of what changed between session state snapshot and current filesystem.

### Tasks

1. [M] **Capture file hashes in session state** — When writing session state (per CLAUDE.md directive), include a `## File Snapshot` section listing files modified during the session with their git status:
   ```markdown
   ## File Snapshot
   - src/app.ts — modified (staged)
   - src/utils/new.ts — new (untracked)
   - tests/app.test.ts — modified (unstaged)
   ```
   - Acceptance: session state files include file snapshot section when files were modified

2. [M] **Diff on recovery** — When `/recover` presents a session, compare the file snapshot against current `git status` and `git diff`:
   - Files in snapshot that still have uncommitted changes → "still pending"
   - Files in snapshot that are now committed → "committed since crash"
   - Files in snapshot that are now gone/reverted → "lost — was modified but changes are gone"
   - Acceptance: recovery summary includes a "Changes" section with diff status

3. [S] **Show actual diff for lost files** — For files marked "lost", attempt `git stash list` and `git reflog` to find recoverable state. Print guidance:
   ```
   Lost changes detected:
   - src/app.ts — changes reverted. Check: git stash list, git reflog
   ```
   - Acceptance: lost files get actionable recovery hints

### Design decisions
- Git-based diffing is reliable and doesn't require storing file contents (which would bloat session files)
- "Lost" detection is best-effort — git reflog covers most crash scenarios
- Don't auto-recover (destructive) — just show the user what happened and let them decide

---

## 4. Standalone Pack — Skill Management Trio

**Current state:** `/do`, `/catalog`, `/recover` live in `whateverai-workflow-skills` alongside `/plan`, `/resume`, `/sync`, `/status`, `/init`, `/align`.

**Goal:** Evaluate whether the skill management trio should be its own pack for users who want routing + recovery without the full workflow system.

### Tasks

1. [S] **Analyze dependencies** — Check if `/do`, `/catalog`, `/recover` reference any other commands or assume workflow conventions (progress files, Linear sync, etc.)
   - `/do`: depends on `~/.claude/skills-reference.md` (generated by `/catalog`) — self-contained
   - `/catalog`: standalone — scans filesystem and session context
   - `/recover`: depends on session state format (CLAUDE.md directive) — this is the coupling point
   - Acceptance: dependency map documented

2. [S] **Decision gate** — Based on dependency analysis, decide:
   - **Option A: Extract to `whateverai-skill-mgmt`** — new pack with just `/do`, `/catalog`, `/recover` + `skill-usage.json` tracking. `/recover` would need to either bundle the session state format spec or reference it.
   - **Option B: Keep bundled** — the session state format is a CLAUDE.md directive, not a pack feature. Extracting `/recover` without the directive makes it incomplete. Keep the trio in workflow-skills.
   - **Recommendation: B (keep bundled)** — `/recover` is tightly coupled to the session persistence directive in CLAUDE.md. Extracting it creates a "half a feature" problem. Users who want just routing can install the pack and ignore the workflow commands.
   - Acceptance: decision documented with rationale

---

## Implementation Order

1. Track invocations (`skill-usage.json`) — foundation for both `/do` and `/catalog` improvements
2. `/do` scoring enhancement — immediate UX improvement
3. `/catalog` usage columns — makes the catalog actionable
4. `/recover` file snapshots — requires CLAUDE.md directive update
5. `/recover` diff view — builds on snapshots
6. Standalone pack decision — evaluate after 1-5 are done

## Size Estimates

- S = small (< 30 min, single file change)
- M = medium (30-60 min, 2-3 file changes + testing)
