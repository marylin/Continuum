# WhateverAI Dev Skills

8 essential development commands for Claude Code. Works in any project with zero setup.

## Installation

```
/plugin add github:marylin/whateverai-commands/whateverai-dev-skills
```

## Commands

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

## Usage

All commands work out of the box. Just invoke them:

```
/build
/test
/debug something is broken in the auth flow
/review
```

Commands that accept arguments pass them via `$ARGUMENTS`. For example:
- `/test auth` — runs only auth-related tests
- `/debug login fails after token refresh` — focuses debugging on that issue

## Behavior Notes

- **`/test` auto-fixes failures:** By default, `/test` will automatically attempt to fix failing tests. If you only want test results without auto-fixing, use `/test` and tell Claude to report only.

## Requirements

- Claude Code CLI
- No additional setup needed

## License

MIT
