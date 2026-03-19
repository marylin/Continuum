# Create Plan (Linear)

Create an implementation plan with Linear issue sync. Analyzes the request, creates a plan in docs/05-Plans/, and syncs to Linear.

<!-- NOTE: Requires Linear MCP connection. Configure your team key in your project's CLAUDE.md. -->

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
- If something goes sideways mid-execution, STOP and re-plan — don't keep going with a broken approach.
- Check docs/06-Development/lessons.md before starting for relevant lessons from past work. If the file doesn't exist, skip — it's optional.

## Linear Sync (on approval)

After I approve the plan, BEFORE starting any code:
1. Detect the current repo name and find the matching Linear project via `list_projects` MCP tool
2. Create a parent issue in Linear:
   - Title: the plan/feature name
   - Project: matched Linear project
   - Label: Feature
   - Status: Todo
   - Description: the plan summary
3. For each M or L complexity task, create a sub-issue under the parent:
   - Title: task description
   - Status: Todo
   - Include complexity marker in description
4. S complexity tasks: list them in the parent issue description — do NOT create sub-issues for them
5. Update the plan .md file: replace `<!-- linear: (pending) -->` with `<!-- linear: TEAM-XX -->` using the parent issue identifier
6. Also write `<!-- linear: TEAM-XX -->` into the progress file header when creating it
7. If no Linear project is found, skip sync silently and proceed — do not block execution

Then execute ALL tasks to completion without asking me anything between tasks.

Request: $ARGUMENTS
