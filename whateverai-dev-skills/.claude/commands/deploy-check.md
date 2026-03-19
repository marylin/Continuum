# Pre-Deploy Checklist

Run a pre-deployment checklist for the current project.

## Instructions
1. **Build**: Run the build command and ensure it passes
2. **Lint**: Run the linter if configured (`npm run lint`, `biome check`, etc.)
3. **Type check**: Run `tsc --noEmit` or equivalent if TypeScript is used
4. **Tests**: Run the test suite if available
5. **Environment**: Check that no `.env` files or secrets are committed (`git status`)
6. **Dependencies**: Check for `package-lock.json` / `bun.lockb` consistency
7. **Git state**: Ensure working directory is clean, all changes committed

Report a summary:
- PASS / FAIL for each check
- Details on any failures
- Overall deploy readiness verdict
