# Security Scan

Perform a security review of the current project.

## Instructions

Detect the project's ecosystem from config files (package.json → npm, pyproject.toml → pip/poetry, Cargo.toml → cargo, go.mod → go, Makefile → make). Adapt commands accordingly.

1. **Secrets**: Search for hardcoded API keys, passwords, tokens in source files
   - Check `.env` files are in `.gitignore`
   - Search for patterns like `api_key`, `secret`, `password`, `token` in source code
2. **Dependencies**: Check for known vulnerabilities
   - Node.js: `npm audit`
   - Python: `pip audit` or `safety check`
   - Rust: `cargo audit`
   - Go: `govulncheck ./...`
   - Review dependency manifests for outdated packages with known CVEs
3. **Code patterns**: Look for common vulnerabilities
   - SQL injection (raw queries without parameterization)
   - XSS (unescaped user input in HTML/JSX)
   - CSRF (missing token validation on mutations)
   - Auth bypass (missing middleware on protected routes)
   - Path traversal (user input in file paths)
4. **Configuration**: Check security headers, CORS settings, cookie flags
5. Report findings by severity: Critical > High > Medium > Low
