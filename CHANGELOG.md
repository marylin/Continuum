# Changelog

## [2.1.0] — 2026-03-31

### Added
- `scripts/auto-checkpoint.sh` — Stop hook that saves basic checkpoint to `.lifecycle/checkpoints/` on session exit
- `scripts/detect-active-work.sh` — SessionStart hook that detects active plans and prompts `/resume`
- `scripts/wip-auto-save.sh` — safety net that stashes uncommitted work to `wip/` branches every 10 edits
- `.lifecycle/activity.md` — rolling activity log (last 20 sessions) written by auto-checkpoint
- `.claude-plugin/hooks/hooks.json` — automatic hook registration on plugin install
- `/recover` Phase 0.5 — checks for WIP safety branches and offers to restore them
- `/resume` Step 4 — shows last 3 sessions from activity log for cross-session context

### Fixed
- Removed hardcoded Windows jq path from `track-file-change.sh` and `track-commit.sh` — now portable across platforms
- README hook documentation now matches actual shipped scripts

### Removed
- Personal vault scripts that don't belong in OSS repo: `read-context.sh`, `update-context.sh`, `vault-init.sh`, `vault-init-all.sh`, `worktree-init.sh`, `gitignore-audit.sh`

## [2.0.0] — 2026-03-25

### Breaking Changes
- Renamed from `whateverai-commands` to `continuum`
- Consolidated 2 plugin packs (17 skills) into 1 pack (7 skills)
- Plans moved from `docs/05-Plans/` to `.lifecycle/plans/` (v1.x paths still checked as fallback)
- Lessons moved from `docs/06-Development/lessons.md` to `.lifecycle/lessons/[topic].md`
- Removed Linear sync integration
- Removed all 8 dev skills (/build, /test, /debug, /deploy-check, /document, /refactor, /review, /security-scan)
- Removed /status, /sync, /do, /catalog skills

### Added
- `/checkpoint` — cognitive snapshots that persist reasoning across sessions
- `/reflect` — extract lessons from completed work and archive plans
- `.lifecycle/` directory system with plans, checkpoints, lessons, and archive
- CLAUDE.md template following Anthropic best practices (<200 lines)
- `.claude/rules/` scaffolding for medium/large projects (path-scoped)
- `scripts/validate.sh` — 4-check validation (frontmatter, count, version, stale refs)
- CI workflow: `validate.yml` replaces `paperclip-ci-notify.yml`

### Changed
- `/init` — creates `.lifecycle/` and modern CLAUDE.md; supports project size tiers
- `/align` — health score (0-10) system; checks `.lifecycle/` compliance and rules hygiene
- `/plan` — writes to `.lifecycle/plans/`; no Linear sync; creates progress file on approval
- `/resume` — reads checkpoints for cognitive state; v1.x fallback for plan locations
- `/recover` — Phase 0 checks checkpoints first; presents cognitive state alongside file recovery

### Migration
- Plans in `docs/05-Plans/` continue to work as fallback
- Lessons in `docs/06-Development/lessons.md` migrated by `/reflect` on first run
- Session hooks are backward compatible

## 1.2.0 (2026-03-23)

### Both packs
- Added `skills/*/SKILL.md` layout — preferred format for Claude skills marketplace
- Each command now has a dedicated `SKILL.md` with frontmatter (name, description, argument-hint)
- Legacy `.claude/commands/` files retained for backward compatibility
- Total: 17 skills across 2 packs (unchanged)

## 1.1.0 (2026-03-23)

### whateverai-dev-skills
- Optimized all 8 skills — removed generic instructions Claude already knows, cut total lines ~50%
- build: removed ecosystem command lists, kept detect+fix loop
- debug: removed vague steps, added specific git log check
- deploy-check: restructured as clean table format
- document: removed type-by-type catalog, focused on style matching
- refactor: removed opportunity list, tightened verify loop
- review: removed redundant style check, tightened
- security-scan: removed per-language command lists, kept OWASP reference
- test: removed emoji from output format (minimal change — already tight)

### whateverai-workflow-skills
- Removed `/plan-linear` — merged Linear sync into `/plan` as optional conditional section
- Optimized all 9 remaining skills — removed fluff, tightened instructions
- catalog: -56% lines, kept algorithm and keyword matching
- do: -42% lines, kept scoring and usage tracking
- recover: -34% lines, kept v2 log + v1 JSON dual-phase recovery
- sync: -38% lines, kept three modes
- init: -39% lines, kept step structure and confirmation gates
- align: tightened step structure
- resume: removed redundant steps, streamlined
- plan: absorbed Linear sync as conditional section
- 10 → 9 commands (18 → 17 total across both packs)

## 1.0.0 (2026-03-19)

### whateverai-dev-skills
- Initial release: build, debug, deploy-check, document, refactor, review, security-scan, test

### whateverai-workflow-skills
- Initial release: align, catalog, do, init, plan, plan-linear, recover, resume, status, sync
