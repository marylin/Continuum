# WhateverAI Workflow Skills

9 opinionated workflow commands for Claude Code. Structured project management with planning, progress tracking, session recovery, and skill routing.

## Installation

```
/plugin add github:marylin/whateverai-commands/whateverai-workflow-skills
```

## Prerequisites

Run `/init` in your project to create the expected folder structure:

```
docs/{01-Discovery,02-Requirements,03-Architecture,04-Design,05-Plans,06-Development,07-Testing,08-Feedback,09-Archive}/
```

### Session Recovery (/recover)

`/recover` uses a two-phase approach:

1. **Primary (log-based):** Reads `~/.claude/sessions/active-changes.log` — written automatically by hooks. No manual setup needed if you have the hooks configured.
2. **Fallback (legacy):** Reads `~/.claude/sessions/session-*.json` from the older v1 session state format.

To annotate the current task in the log (optional but recommended for multi-step work):
```
echo "STATE: <one sentence describing current task>" >> ~/.claude/sessions/active-changes.log
```

## Commands

| Command | Description | Requires |
|---------|-------------|----------|
| `/align` | Audit project against workflow standards | docs/ structure |
| `/catalog` | Scan and categorize all installed skills | — |
| `/do` | Smart skill router — describe what you need | `/catalog` run first |
| `/init` | Initialize project with workflow structure | — |
| `/plan` | Create plans with progress tracking + optional Linear sync | docs/05-Plans/ |
| `/recover` | Recover crashed/interrupted sessions | Hooks (auto) or legacy session files |
| `/resume` | Resume in-progress features | docs/05-Plans/ |
| `/status` | Show active progress state | docs/05-Plans/ |
| `/sync` | Sync work to Linear (history, recent, status modes) | Linear MCP |

## Linear Integration

`/plan` includes optional Linear sync (auto-skips if no Linear MCP). `/sync` provides three modes for ongoing sync. All other commands work without Linear.

## Conventions

### Progress Files

Plans: `docs/05-Plans/[name]-plan.md`. Progress: `docs/05-Plans/[name]-progress.md`.

```
[x] done  [~] in progress  [ ] pending  [!] blocked
```

Complexity: `[S]` <30min, `[M]` 1-3hrs, `[L]` 3hrs+

### Skills Reference

`/catalog` writes `~/.claude/skills-reference.md`. `/do` reads it for intent routing. Run `/catalog` after plugin changes.

Both `/catalog` and `/do` track usage via `~/.claude/skill-usage.jsonl` (appended on each invocation). The catalog uses this to show a **Most Used (30d)** section and per-skill `Last Used` / `Uses (30d)` columns. `/do` boosts frequently-used skills in its scoring.

## License

MIT
