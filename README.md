# WhateverAI Claude Skills

Two Claude Code plugin packs by [WhateverAI](https://whateverai.dev). 18 commands across two plugin packs.

## Packs

### [whateverai-dev-skills](./whateverai-dev-skills/) — Universal (8 commands)

Works in any project with zero setup. Essential development commands.

```
/plugin add github:whateverai-dev/claude-skills/whateverai-dev-skills
```

| Command | Description |
|---------|-------------|
| `/build` | Build project and resolve errors |
| `/debug` | Investigate and diagnose bugs |
| `/deploy-check` | Pre-deployment checklist |
| `/document` | Generate documentation |
| `/refactor` | Refactor with behavior preservation |
| `/review` | Code review against base branch |
| `/security-scan` | Security vulnerability scan |
| `/test` | Run test suite (full or filtered) |

### [whateverai-workflow-skills](./whateverai-workflow-skills/) — Opinionated (10 commands)

Structured workflow with planning, progress tracking, session recovery, and skill routing. Requires adopting the `docs/` folder convention (created by `/init`).

```
/plugin add github:whateverai-dev/claude-skills/whateverai-workflow-skills
```

| Command | Description | Requires |
|---------|-------------|----------|
| `/align` | Audit project against workflow standards | docs/ structure |
| `/catalog` | Scan and categorize all installed skills | — |
| `/do` | Smart skill router — describe what you need | `/catalog` run first |
| `/init` | Initialize project with workflow structure | — |
| `/plan` | Create plans with local progress tracking | docs/05-Plans/ |
| `/plan-linear` | Create plans with Linear issue sync | Linear MCP |
| `/recover` | Recover crashed/interrupted sessions | Session state convention |
| `/resume` | Resume in-progress features | docs/05-Plans/ |
| `/status` | Show active progress state | docs/05-Plans/ |
| `/sync` | Sync work to Linear | Linear MCP |

## Quick Start

1. Install the pack(s) you want
2. For dev-skills: just use the commands — they work immediately
3. For workflow-skills: run `/init` in your project first, then use `/plan` to start planning

## Author

**Marylin Alarcon** — Tech Lead, AI builder, solo founder. Building from Medellin for the world.

- [WhateverAI](https://whateverai.dev)
- [LinkedIn](https://linkedin.com/in/marylinalarcon)

## License

MIT
