<div align="center">

# Continuum

**Your Claude Code sessions finally have memory.**

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.1.0-green.svg)](https://github.com/marylin/Continuum/releases/tag/v2.1.0)
[![CI](https://github.com/marylin/Continuum/actions/workflows/validate.yml/badge.svg)](https://github.com/marylin/Continuum/actions)
[![Claude Code Plugin](https://img.shields.io/badge/Claude_Code-plugin-blueviolet.svg)](https://docs.anthropic.com/en/docs/claude-code)
[![23 Tests](https://img.shields.io/badge/tests-23_passing-brightgreen.svg)](tests/test-hooks.sh)

Crash mid-feature? Context gone after `/compact`? Forgot what you were doing yesterday?<br/>
**Continuum fixes all of that.** 7 skills + 5 zero-cost hooks that track your work, save your reasoning, and pick up exactly where you left off.

```
/install github:marylin/continuum
```

</div>

---

## The Problem

Claude Code sessions are **completely stateless**. Every crash, every new session, every `/compact` — your context is gone. You lose what you were working on, what decisions you made, and why. You start over. Every. Single. Time.

## The Fix

```
init → align → plan → resume ⇄ checkpoint
                 ↑        ↓         ↓
              reflect   recover (crash)
                 ↑         ↓
                 └─────────┘
```

Continuum gives your sessions a lifecycle. **Plan** your work. **Resume** where you left off. **Checkpoint** your reasoning. **Recover** from crashes. **Reflect** on what you learned. Every session builds on the last.

## What Happens After You Install

**Session starts:** "Active work detected: `auth-system` — 4/8 tasks done. Run `/resume` to continue."

**You run `/resume`:** Shows your progress, your last checkpoint (what you were thinking, decisions made, gotchas), and the last 3 sessions of activity. Picks up from the exact next task.

**You work:** Every 10 edits, your uncommitted code is silently stashed to a `wip/` safety branch. File changes and commits are logged for crash recovery.

**Session ends:** Auto-checkpoint saves your branch, progress, and recent files. Activity log updated.

**You crash:** `/recover` finds your WIP branches, checkpoint files, and crash logs. Nothing is lost.

**Zero tokens consumed by any of this.** All hooks run as shell scripts.

## Skills

| Skill | What it does |
|:------|:-------------|
| **`/init`** | Bootstrap a project with CLAUDE.md and `.lifecycle/` |
| **`/plan`** | Sized tasks with acceptance criteria — start executing immediately |
| **`/resume`** | Pick up where you left off — progress, cognitive state, recent activity |
| **`/checkpoint`** | Save *what you're thinking and why* — not just what files changed |
| **`/recover`** | Crashed? WIP branches + crash logs + checkpoints = nothing lost |
| **`/reflect`** | Extract lessons from completed work, archive the plan |
| **`/align`** | Health-check your project structure (0-10 score) |

## Three Layers of Protection

| Layer | What | When | Cost |
|:------|:-----|:-----|:-----|
| **WIP auto-save** | Stashes uncommitted work to `wip/` branches | Every 10 edits | 0 tokens |
| **Activity log** | Rolling session history in `.lifecycle/activity.md` | Every session end | 0 tokens |
| **Cognitive checkpoint** | Your reasoning, decisions, and gotchas | Manual or auto | 0 tokens (auto) |

> Most plugins just say "sorry, start over" when something goes wrong.<br/>
> Continuum actually recovers your work.

## Quick Start

```bash
/install github:marylin/continuum    # install the plugin
/init                                 # set up your project
/plan add user authentication         # plan a feature
# ... work through tasks ...
/checkpoint                           # save your reasoning before a break
/resume                               # next session — picks up exactly here
/reflect                              # done? extract lessons, archive the plan
```

## How It Works

**Tier 1 — Skills only (zero setup):** `/plan` → work → `/checkpoint` → `/resume` → `/reflect`. Everything lives in `.lifecycle/` files. No hooks needed.

**Tier 2 — With hooks (automatic on install):** Session hooks fire automatically and enhance the experience:

| Hook | Script | What it does |
|:-----|:-------|:-------------|
| **SessionStart** | `detect-active-work.sh` | Prompts you to `/resume` |
| **Stop** | `auto-checkpoint.sh` | Saves checkpoint + activity log |
| **PostToolUse** | `track-file-change.sh` | Logs file changes for `/recover` |
| **PostToolUse** | `track-commit.sh` | Logs commits for `/recover` |
| **PostToolUse** | `wip-auto-save.sh` | Stashes to `wip/` every 10 edits |

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

## What It Creates

```
your-project/
└── .lifecycle/                   ← you choose: tracked or gitignored
    ├── plans/                    ← sized tasks + progress tracking
    ├── checkpoints/              ← cognitive snapshots (auto + manual)
    ├── lessons/                  ← patterns extracted by /reflect
    ├── activity.md               ← rolling log of last 20 sessions
    └── archive/                  ← completed work
```

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (CLI, desktop, or IDE extension)
- Git
- [jq](https://jqlang.github.io/jq/) (optional — for session tracking hooks)

## Migration from v1.x

If you used the previous version of this plugin:

- Plans in `docs/05-Plans/` continue to work — `/resume` checks both locations
- Lessons in `docs/06-Development/lessons.md` are migrated by `/reflect` on first run
- Run `/init` then `/align` to migrate to `.lifecycle/`

## Uninstall

```
/uninstall github:marylin/continuum
```

Your `.lifecycle/` directory and all your plans, checkpoints, and lessons are untouched.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — [Marylin Alarcon](https://github.com/marylin)
