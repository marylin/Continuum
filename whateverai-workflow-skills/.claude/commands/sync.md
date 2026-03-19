<!-- NOTE: Requires Linear MCP connection. -->

Sync local work with Linear. Three modes based on $ARGUMENTS:

## Mode: `history` (or `sync-history`)
One-time retroactive sync of existing plan/progress files to Linear.

Steps:
1. Detect the current project by reading the repo name from the working directory
2. Map the repo name to its Linear project using the MCP tool `list_projects` (search by name)
3. If no Linear project exists, tell me and stop
4. Read all files in `docs/05-Plans/` and `docs/09-Archive/`
5. For each COMPLETED plan (all tasks `[x]` or in archive):
   - Create ONE summary issue in Linear: title = plan name, status = Done, label = Feature
   - Description = plan summary + "Completed tasks: X" + key outcomes from progress file
   - Do NOT create individual sub-issues for completed work
6. For each ACTIVE plan (has `[ ]` or `[~]` tasks):
   - Create a parent issue: title = plan name, status = In Progress, label = Feature
   - For each M or L complexity task only, create a sub-issue under the parent
   - S complexity tasks: list them in the parent issue description, not as sub-issues
   - Set sub-issue status: `[x]` → Done, `[~]` → In Progress, `[ ]` → Todo, `[!]` → Todo + "Blocked" label
7. Write `<!-- linear: TEAM-XX -->` into the header of each synced .md file (line 2, after the title)
8. Report what was created

## Mode: `recent` (or `sync-recent`, or no arguments)
Catch up from recent git activity. Default mode when no arguments given.

Steps:
1. Detect current project and map to Linear project
2. Run `git log --oneline --since="last Monday" --all` to find recent work
3. Group commits by branch/feature
4. For each group:
   - Check if a Linear issue already exists (search by branch name or commit message keywords)
   - IF no issue exists AND commits are `feat` or `fix` type → create an issue in Linear
     - Title: feature description from commit messages
     - Status: Done (if merged to main), In Progress (if branch still open)
     - Label: feat → Feature, fix → Bug
   - IF issue exists → update its status based on branch state
   - Skip `docs`, `refactor`, `test` commits UNLESS they mention failing tests
5. Check for issues marked In Progress in Linear but with no git activity in 7+ days → flag as potentially stale
6. Report: new issues created, issues updated, stale issues flagged

## Mode: `status` (or `sync-status`)
Reconcile local .md progress files with Linear issue states.

Steps:
1. Detect current project and map to Linear project
2. Read all active progress files in `docs/05-Plans/`
3. For each file that has a `<!-- linear: TEAM-XX -->` header:
   - Read the Linear parent issue and its sub-issues via MCP
   - Compare local `[x]/[~]/[ ]/[!]` states with Linear issue statuses
   - Update Linear sub-issues to match local progress (local is source of truth during active work)
   - Report discrepancies
4. For progress files WITHOUT a `<!-- linear: -->` header:
   - These haven't been synced yet — offer to run `sync history` for them
5. Check for Linear issues with no matching local file → report as "Linear-only issues"

## General Rules
- Never create duplicate issues — always search Linear first before creating
- Use the `save_issue` MCP tool to create/update issues
- Map commit types to labels: `feat` → Feature, `fix` → Bug, `refactor`/`test`/`docs` → Improvement
- Set priority based on complexity: L → High, M → Medium, S → Low
- One line of output per action taken. No prose.
- If the Linear project is not found, list available projects and ask which to use

Arguments: $ARGUMENTS
