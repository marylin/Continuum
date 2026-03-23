---
name: build
description: Build the project and fix any errors until it passes
argument-hint: [options]
---

# Build Project

Build the project and fix any errors until it passes.

1. Detect ecosystem from config files and run the appropriate build command
2. If the build fails, fix errors one at a time and re-run after each fix
3. Report: pass/fail, errors fixed (if any), remaining issues (if any)

$ARGUMENTS
