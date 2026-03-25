# Continuum

Your Claude Code sessions remember, recover, and learn.

---

Claude Code sessions are stateless. When you crash, switch tasks, or come back tomorrow, all context is gone. Continuum is 7 skills that give your sessions memory.

```
init → align → plan → resume ⇄ checkpoint
                 ↑        ↓         ↓
              reflect   recover (crash)
                 ↑         ↓
                 └─────────┘
```

## Install

```
/install github:marylin/continuum
```

## Skills

| Skill | What it does |
|-------|-------------|
| `/init` | Bootstrap a project with CLAUDE.md and `.lifecycle/` directory |
| `/align` | Audit project structure and lifecycle compliance (0-10 health score) |
| `/plan` | Create a structured plan with sized tasks and acceptance criteria |
| `/resume` | Pick up where you left off — shows progress and cognitive state |
| `/checkpoint` | Save a cognitive snapshot of what you're doing and why |
| `/recover` | Recover work from a crashed or interrupted session |
| `/reflect` | Extract lessons from completed work, then archive the plan |

## Quick Start

1. `/init` your project — sets up CLAUDE.md and `.lifecycle/`
2. `/plan` a feature — creates sized tasks with acceptance criteria
3. Work through tasks — continuum tracks progress
4. `/checkpoint` before breaks — saves your reasoning and decisions
5. `/resume` next session — picks up exactly where you left off
6. `/reflect` when done — extracts lessons for future work

## Session Hooks (optional)

For crash recovery (`/recover`), install session tracking hooks that log file changes and commits. Add to your Claude Code `settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "bash /path/to/continuum/scripts/track-file-change.sh \"$TOOL_INPUT\""
      },
      {
        "matcher": "Bash",
        "command": "bash /path/to/continuum/scripts/track-commit.sh \"$TOOL_INPUT\""
      }
    ],
    "Stop": [
      {
        "command": "bash /path/to/continuum/scripts/assemble-session-state.sh"
      }
    ],
    "SessionStart": [
      {
        "command": "bash /path/to/continuum/scripts/check-stale-sessions"
      }
    ]
  }
}
```

Without hooks, `/recover` still works with checkpoint files and legacy session data.

## What continuum creates in your projects

```
project/
├── CLAUDE.md                     ← <200 lines, always loaded
├── .claude/rules/                ← path-scoped, on demand (medium/large projects)
└── .lifecycle/                   ← tracked or gitignored (you choose)
    ├── plans/                    ← active plans + progress files
    ├── checkpoints/              ← cognitive snapshots
    ├── lessons/                  ← topic-based learned patterns
    └── archive/                  ← completed plans + checkpoints
```

## License

MIT — Marylin Alarcon
