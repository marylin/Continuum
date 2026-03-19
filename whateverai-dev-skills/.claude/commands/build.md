# Build Project

Build the current project and resolve any build errors.

## Instructions
1. Detect the project's ecosystem from config files (package.json → npm/bun, pyproject.toml → pip/poetry, Cargo.toml → cargo, go.mod → go, Makefile → make). Adapt commands accordingly.
2. Common build commands:
   - Node.js: `npm run build`, `bun run build`, `npx next build`
   - Python: `python -m build`, `poetry build`
   - Rust: `cargo build --release`
   - Go: `go build ./...`
   - Docker: `docker build`
   - Make: `make build`
3. Run the appropriate build command
4. If the build fails:
   - Read the full error output carefully
   - Identify the root cause (type errors, missing imports, config issues)
   - Fix the errors one at a time
   - Re-run the build after each fix
5. Report the final build status (success or remaining issues)

$ARGUMENTS
