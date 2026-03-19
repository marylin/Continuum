# Pre-Deploy Checklist

Run a pre-deployment checklist for the current project.

## Instructions

Detect the project's ecosystem from config files (package.json → npm, pyproject.toml → pip/poetry, Cargo.toml → cargo, go.mod → go, Makefile → make). Adapt commands accordingly.

1. **Build**: Run the build command and ensure it passes
2. **Lint**: Run the linter if configured (`npm run lint`, `biome check`, `ruff check`, `golangci-lint run`, `cargo clippy`, etc.)
3. **Type check**: Run `tsc --noEmit` (TypeScript), `mypy` (Python), or equivalent if applicable
4. **Tests**: Run the test suite if available (`npm test`, `pytest`, `go test ./...`, `cargo test`, etc.)
5. **Environment**: Check that no `.env` files or secrets are committed (`git status`)
6. **Dependencies**: Check for lockfile consistency (package-lock.json, bun.lockb, poetry.lock, Cargo.lock, go.sum)
7. **Git state**: Ensure working directory is clean, all changes committed

Report a summary:
- PASS / FAIL for each check
- Details on any failures
- Overall deploy readiness verdict
