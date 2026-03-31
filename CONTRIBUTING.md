# Contributing to Continuum

Thanks for your interest in contributing!

## How to Contribute

### Reporting Issues

- Use [GitHub Issues](https://github.com/marylin/continuum/issues)
- Include your Claude Code version, OS, and steps to reproduce
- For hook issues, check `~/.claude/debug/hook-failures.log` and include relevant lines

### Submitting Changes

1. Fork the repo
2. Create a branch: `feat/your-feature` or `fix/your-fix`
3. Make your changes
4. Run validation: `bash scripts/validate.sh`
5. Submit a PR against `master`

### Development Setup

```bash
git clone https://github.com/marylin/continuum.git
cd continuum
bash scripts/validate.sh  # should pass
```

To test locally without publishing:

```bash
# Point Claude Code to your local clone
/install /path/to/your/local/continuum
```

### Writing Skills

Skills live in `skills/<name>/SKILL.md` with this format:

```markdown
---
name: skill-name
description: One-line description shown in skill listings
argument-hint: [optional arguments]
---

# Skill Title

Instructions for Claude to follow when this skill is invoked.
```

Rules:
- `name` in frontmatter must match the directory name
- Update `plugin.json` description if you change the skill count
- Run `bash scripts/validate.sh` — it checks frontmatter, skill count, version, and stale references

### Writing Hook Scripts

Scripts live in `scripts/` and are bash shell scripts. Rules:

- Must read CWD from stdin JSON (Claude Code passes hook context via stdin)
- Must exit 0 on all code paths — hooks must never block Claude Code
- Must not invoke the LLM (zero token cost)
- Use `set -euo pipefail` for safety
- Normalize paths with `CWD="${CWD//\\//}"` for Windows compatibility
- Only activate if `.lifecycle/` exists in the project (check early, exit 0 if not)

### Validation

`scripts/validate.sh` runs 4 checks:

1. Every `skills/*/SKILL.md` has valid `name` and `description` frontmatter
2. Skill count matches the number in `plugin.json` description
3. Version in `plugin.json` is valid semver
4. No stale references to old branding (`whateverai`, `dev-skills`, etc.)

CI runs this on every push and PR to `master`.

## Code of Conduct

Be kind, be constructive. We're all here to build better tools.
