# WhateverAI Workflow Skills

10 opinionated workflow commands for Claude Code. Structured project management with planning, progress tracking, session recovery, and skill routing.

## Installation

```
/plugin add github:whateverai-dev/claude-skills/whateverai-workflow-skills
```

## Prerequisites

Run `/init` in your project to create the expected folder structure:

```
docs/
  01-Discovery/
  02-Requirements/
  03-Architecture/
  04-Design/
  05-Plans/
  06-Development/
  07-Testing/
  08-Feedback/
  09-Archive/
```

## Commands

| Command | Description | Requires |
|---------|-------------|----------|
| `/align` | Audit project against workflow standards | docs/ structure |
| `/catalog` | Scan and categorize all installed skills | — |
| `/do` | Smart skill router — describe what you need | `/catalog` run first |
| `/init` | Initialize project with workflow structure | — |
| `/plan` | Create implementation plans with progress tracking | docs/05-Plans/ |
| `/plan-linear` | Create plans with Linear issue sync | Linear MCP |
| `/recover` | Recover crashed/interrupted sessions | Session state convention |
| `/resume` | Resume in-progress features | docs/05-Plans/ |
| `/status` | Show active progress state | docs/05-Plans/ |
| `/sync` | Sync work to Linear | Linear MCP |

## Linear Integration

Two commands require the Linear MCP server: `/plan-linear` and `/sync`. All other commands work without Linear.

To configure Linear, add your team key to your project's CLAUDE.md:
```
## Linear
Team key: YOUR-TEAM-KEY (e.g., ENG, PROD, etc.)
```

## Conventions

### Progress Files

Plans live in `docs/05-Plans/[name]-plan.md`. Progress is tracked in `docs/05-Plans/[name]-progress.md`.

**Format:**
```
[x] done task
[~] in progress task
[ ] pending task
[!] blocked task
```

**Complexity markers in plans:**
```
1. [S] Small task — one-line acceptance criteria
2. [M] Medium task — criteria
3. [L] Large task — criteria
```

### Session State Persistence (for /recover)

The `/recover` command works with a session state system. To enable it, add this to your global `~/.claude/CLAUDE.md`:

**Session state files** are written by Claude at checkpoints during multi-step work:
- Per-project: `docs/05-Plans/.session-<id>.md` (add `docs/05-Plans/.session-*.md` to .gitignore)
- Global index: `~/.claude/sessions/session-<id>.json`

Add a directive to your CLAUDE.md telling Claude to write session state:
```
## Session State Persistence
Maintain session state files to survive unexpected CLI closures.
- On entering any multi-step task (3+ steps) → create initial state
- After each meaningful milestone → update state
- On completion → delete session files
- BEFORE /compact → update state (mandatory)
```

### Skills Reference (for /catalog and /do)

`/catalog` scans all installed skills and writes `~/.claude/skills-reference.md`. `/do` reads this file to route by intent. Run `/catalog` after installing or removing plugins.

## License

MIT
