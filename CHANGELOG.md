# Changelog

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
