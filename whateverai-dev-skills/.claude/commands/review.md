# Code Review

Review the code changes in the current branch compared to the base branch.

## Instructions
1. Run `git diff main...HEAD` (or `git diff master...HEAD`) to see all changes
2. If no branch diff exists, review staged changes with `git diff --cached` or recent uncommitted changes with `git diff`
3. For each changed file, analyze:
   - **Correctness**: Logic errors, edge cases, off-by-one errors
   - **Security**: Injection vulnerabilities, exposed secrets, auth issues
   - **Performance**: N+1 queries, unnecessary re-renders, memory leaks
   - **Style**: Consistency with project conventions
   - **Types**: Missing or incorrect TypeScript types (if applicable)
4. Present findings grouped by severity: Critical > Warning > Suggestion
5. For each finding, reference the specific file and line number
6. End with an overall summary and a pass/needs-changes verdict
