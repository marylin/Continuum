---
name: plan
description: Create a structured implementation plan with tasks, estimates, and optional Linear sync
argument-hint: <feature or request>
---

# Create Plan

Analyze this request. Create `docs/05-Plans/[descriptive-name]-plan.md` using this exact format:

# [Feature Name] Plan
<!-- linear: (pending) -->

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
- If something goes sideways mid-execution, STOP and re-plan.
- Check docs/06-Development/lessons.md before starting (skip if missing).

## Linear Sync (on approval, if Linear MCP available)

After approval, BEFORE starting code:
1. Find the matching Linear project via `list_projects` MCP tool
2. Create a parent issue: title = plan name, status = Todo, label = Feature
3. For each M/L task, create a sub-issue under the parent. S tasks go in parent description only.
4. Update plan header: replace `<!-- linear: (pending) -->` with `<!-- linear: TEAM-XX -->`
5. If no Linear MCP or no project found, skip sync silently — do not block execution

Then execute ALL tasks to completion without asking me anything between tasks.

Request: $ARGUMENTS
