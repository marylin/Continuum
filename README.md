# Continuum

Your Claude Code sessions remember, recover, and learn.

---

Claude Code sessions are stateless. When you crash, switch tasks, or come back tomorrow, all context is gone. Continuum is a Claude Code plugin with 7 skills and 5 session hooks that give your sessions memory.

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

**Requirements:**
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (CLI, desktop, or IDE extension)
- [jq](https://jqlang.github.io/jq/) — for session tracking hooks (optional; hooks exit silently without it)
- Git — for WIP auto-save and crash recovery features

## Skills

| Skill | What it does |
|-------|-------------|
| `/init` | Bootstrap a project with CLAUDE.md and `.lifecycle/` directory |
| `/align` | Audit project structure and lifecycle compliance (0-10 health score) |
| `/plan` | Create a structured plan with sized tasks and acceptance criteria |
| `/resume` | Pick up where you left off — shows progress, cognitive state, and recent activity |
| `/checkpoint` | Save a cognitive snapshot of what you're doing and why |
| `/recover` | Recover work from a crashed or interrupted session |
| `/reflect` | Extract lessons from completed work, then archive the plan |

## Quick Start

```bash
# 1. Initialize your project
/init

# 2. Plan a feature
/plan add user authentication

# 3. Work through tasks — Continuum tracks progress automatically

# 4. Taking a break? Save your reasoning
/checkpoint

# 5. Next session — pick up exactly where you left off
/resume

# 6. Feature done? Extract lessons for future work
/reflect
```

## How It Works

### Tier 1 — Skills only (no hooks needed)

The core loop works entirely through `.lifecycle/` files:

```
/plan → work → /checkpoint → /resume → /reflect
```

`/resume` reads your progress files and checkpoints. `/checkpoint` saves your reasoning. No hooks required.

### Tier 2 — With session hooks (automatic on install)

Continuum registers hooks that enhance the experience automatically:

| Hook | Script | What it does |
|------|--------|-------------|
| **SessionStart** | `detect-active-work.sh` | Detects active plans, prompts you to `/resume` |
| **Stop** | `auto-checkpoint.sh` | Auto-saves checkpoint + appends to rolling activity log |
| **PostToolUse** | `track-file-change.sh` | Tracks file changes for crash recovery (`/recover`) |
| **PostToolUse** | `track-commit.sh` | Tracks commits for crash recovery (`/recover`) |
| **PostToolUse** | `wip-auto-save.sh` | Stashes uncommitted work to `wip/` branch every 10 edits |

All hooks run as shell commands with **zero token cost** — they never invoke the LLM.

Session tracking hooks (`track-file-change.sh`, `track-commit.sh`) require [jq](https://jqlang.github.io/jq/). If jq is not installed, those hooks exit silently — everything else still works.

<details>
<summary>Manual hook setup (if not using plugin install)</summary>

Add to your Claude Code `settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "bash /path/to/continuum/scripts/track-file-change.sh", "timeout": 2000 },
          { "type": "command", "command": "bash /path/to/continuum/scripts/wip-auto-save.sh", "timeout": 3000 }
        ]
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

## Three Layers of Protection

Continuum protects your work at three levels:

| Layer | How | When |
|-------|-----|------|
| **WIP auto-save** | Stashes uncommitted work to `wip/` branches | Every 10 file edits |
| **Activity log** | Records session summaries to `.lifecycle/activity.md` | Every session end |
| **Cognitive checkpoint** | Captures your reasoning, decisions, and gotchas | Manual (`/checkpoint`) or auto on session end |

When things go wrong, `/recover` checks all three: WIP branches, crash logs, and checkpoint files.

## What Continuum Creates in Your Projects

```
project/
├── CLAUDE.md                     ← <200 lines, only what Claude can't infer
├── .claude/rules/                ← path-scoped rules (medium/large projects)
└── .lifecycle/                   ← tracked or gitignored (you choose during /init)
    ├── plans/                    ← active plans + progress files
    ├── checkpoints/              ← cognitive snapshots (auto + manual)
    ├── lessons/                  ← topic-based patterns from /reflect
    ├── activity.md               ← rolling log of last 20 sessions
    └── archive/                  ← completed plans + old checkpoints
```

## Migration from v1.x

If you used the previous version of this plugin:

- Plans in `docs/05-Plans/` continue to work — `/resume` and `/plan` check both locations
- Lessons in `docs/06-Development/lessons.md` are migrated by `/reflect` on first run
- Dev skills (`/build`, `/test`, `/debug`, etc.) were removed — use Claude's built-in capabilities
- Run `/init` then `/align` to migrate to the `.lifecycle/` structure

## Uninstall

```
/uninstall github:marylin/continuum
```

This removes the plugin and its hooks. The `.lifecycle/` directory in your projects is untouched — your plans, checkpoints, and lessons remain.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT — [Marylin Alarcon](https://github.com/marylin)
