# Debug Issue

Investigate and diagnose a bug or unexpected behavior.

## Instructions
1. Understand the reported issue from the user's description
2. Search the codebase for relevant files:
   - Trace the code path from entry point to the problem area
   - Check recent git changes that might have introduced the issue: `git log --oneline -20`
3. Identify the root cause:
   - Look for logic errors, race conditions, type mismatches
   - Check environment variables and configuration
   - Review error messages and stack traces if provided
4. Propose a fix with explanation
5. If the fix is clear and safe, implement it
6. If multiple possible causes exist, list them ranked by likelihood

$ARGUMENTS
