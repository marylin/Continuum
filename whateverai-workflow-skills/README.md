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

### Session State Persistence (required for /recover)

Add to your `~/.claude/CLAUDE.md`:

```
## Session State Persistence
Maintain session state files to survive unexpected CLI closures.
- On entering any multi-step task (3+ steps) → create initial state
- After each meaningful milestone → update state
- On completion → delete session files
- BEFORE /compact → update state (mandatory)
```

Session state files: per-project `docs/05-Plans/.session-<id>.md` (gitignore these) and global `~/.claude/sessions/session-<id>.json`.

## Commands

| Command | Description | Requires |
|---------|-------------|----------|
| `/align` | Audit project against workflow standards | docs/ structure |
| `/catalog` | Scan and categorize all installed skills | — |
| `/do` | Smart skill router — describe what you need | `/catalog` run first |
| `/init` | Initialize project with workflow structure | — |
| `/plan` | Create plans with progress tracking + optional Linear sync | docs/05-Plans/ |
| `/recover` | Recover crashed/interrupted sessions | Session state convention |
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

## License

MIT
