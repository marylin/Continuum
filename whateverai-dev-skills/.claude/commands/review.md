# Code Review

Review code changes in the current branch against the base branch.

1. Get the diff: `git diff main...HEAD` (fall back to `git diff --cached` or `git diff`)
2. Review each changed file for:
   - **Correctness**: logic errors, edge cases, off-by-one
   - **Security**: injection, exposed secrets, auth gaps
   - **Performance**: N+1 queries, re-renders, memory leaks
   - **Types**: missing or incorrect types
3. Group findings by severity: Critical > Warning > Suggestion
4. Reference specific file:line for each finding
5. End with pass/needs-changes verdict
