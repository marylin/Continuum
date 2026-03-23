# Security Scan

Security review of the current project. Detect ecosystem from config files.

1. **Secrets** -- search source for hardcoded keys/passwords/tokens, verify `.env` is gitignored
2. **Dependencies** -- run the ecosystem's audit command (`npm audit`, `pip audit`, `cargo audit`, `govulncheck`)
3. **Code patterns** -- scan for OWASP top 10: SQL injection, XSS, CSRF, auth bypass, path traversal
4. **Configuration** -- check CORS, security headers, cookie flags

Report findings by severity: Critical > High > Medium > Low
