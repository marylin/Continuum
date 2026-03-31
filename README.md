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

## How it works

**Tier 1 — Skills only (no setup):**

The core loop works entirely through `.lifecycle/` files:

```
/plan → work → /checkpoint → /resume → /reflect
```

`/resume` reads your progress files and checkpoints. `/checkpoint` saves your reasoning. No hooks needed.

**Tier 2 — With session hooks (automatic on install):**

Continuum registers hooks that enhance the experience:

| Hook | What it does |
|------|-------------|
| **SessionStart** | Detects active plans, prompts you to `/resume` |
| **Stop** | Auto-saves basic checkpoint (branch, progress, recent files) |
| **PostToolUse** | Tracks file changes and commits for crash recovery (`/recover`) |

Session tracking hooks require [jq](https://jqlang.github.io/jq/). If jq is not installed, tracking hooks exit silently — everything else still works.

<details>
<summary>Manual hook setup (if not using plugin install)</summary>

Add to your Claude Code `settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": "bash /path/to/continuum/scripts/track-file-change.sh", "timeout": 2000 }]
      },
      {
        "matcher": "Bash(git commit*)",
        "hooks": [{ "type": "command", "command": "bash /path/to/continuum/scripts/track-commit.sh", "timeout": 3000 }]
      }
    ],
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [{ "type": "command", "command": "bash /path/to/continuum/scripts/detect-active-work.sh", "timeout": 3000 }]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [{ "type": "command", "command": "bash /path/to/continuum/scripts/auto-checkpoint.sh", "timeout": 5000 }]
      }
    ]
  }
}
```

</details>

Without hooks, `/recover` still works with checkpoint files.

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
