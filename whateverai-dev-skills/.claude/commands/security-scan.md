# Security Scan

Perform a security review of the current project.

## Instructions
1. **Secrets**: Search for hardcoded API keys, passwords, tokens in source files
   - Check `.env` files are in `.gitignore`
   - Search for patterns like `api_key`, `secret`, `password`, `token` in source code
2. **Dependencies**: Check for known vulnerabilities
   - Run `npm audit` if Node.js project
   - Review `package.json` for outdated packages with known CVEs
3. **Code patterns**: Look for common vulnerabilities
   - SQL injection (raw queries without parameterization)
   - XSS (unescaped user input in HTML/JSX)
   - CSRF (missing token validation on mutations)
   - Auth bypass (missing middleware on protected routes)
   - Path traversal (user input in file paths)
4. **Configuration**: Check security headers, CORS settings, cookie flags
5. Report findings by severity: Critical > High > Medium > Low
