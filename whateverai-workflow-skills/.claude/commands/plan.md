Analyze this request. Create `docs/05-Plans/[descriptive-name]-plan.md` using this exact format:

# [Feature Name] Plan

## Summary
[2-3 sentences max. What we're building and why.]

## Tasks
1. [S] Task — acceptance criteria in one line
2. [M] Task — criteria
3. [L] Task — criteria

## Dependencies
[Only if tasks depend on each other. Skip if none.]

## Open Questions
[Anything ambiguous. Skip if clear.]

Rules:
- One line per task. No paragraphs, no prose descriptions.
- Complexity: S = <30min, M = 1-3hrs, L = 3hrs+
- Reference external docs instead of inlining: `See docs/03-Architecture/...`
- Write detailed specs upfront to reduce ambiguity during execution.
- Show me the summary and questions. Do NOT code until I approve.
- If something goes sideways mid-execution, STOP and re-plan — don't keep going with a broken approach.
- Check docs/06-Development/lessons.md before starting for relevant lessons from past work.

Then execute ALL tasks to completion without asking me anything between tasks.

Request: $ARGUMENTS
