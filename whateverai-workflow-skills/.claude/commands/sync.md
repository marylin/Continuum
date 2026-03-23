# Sync to Linear

Sync local work with Linear. Three modes based on $ARGUMENTS:

<!-- Requires Linear MCP connection. -->

## Mode: `history` (or `sync-history`)
One-time retroactive sync of existing plan/progress files.

1. Map current repo to its Linear project via `list_projects`
2. For each **completed** plan (all `[x]` or in archive): create one summary issue (Done, Feature label)
3. For each **active** plan: create parent issue + sub-issues for M/L tasks. S tasks in parent description only.
4. Set sub-issue status: `[x]`→Done, `[~]`→In Progress, `[ ]`→Todo, `[!]`→Todo + Blocked label
5. Write `<!-- linear: TEAM-XX -->` into each synced .md header
6. Report what was created

## Mode: `recent` (default, or `sync-recent`)
Catch up from recent git activity.

1. Map repo to Linear project
2. `git log --oneline --since="last Monday" --all` → group by branch/feature
3. For each group:
   - Search Linear for existing issue (by branch name or commit keywords)
   - No issue + `feat`/`fix` commits → create issue. `feat`→Feature, `fix`→Bug label
   - Existing issue → update status (merged=Done, open branch=In Progress)
   - Skip `docs`/`refactor`/`test` commits unless they mention failures
4. Flag issues In Progress in Linear with no git activity in 7+ days as stale
5. Report: created, updated, stale

## Mode: `status` (or `sync-status`)
Reconcile local progress files with Linear states.

1. Map repo to Linear project
2. For each progress file with `<!-- linear: TEAM-XX -->`: compare local states with Linear, update Linear (local is source of truth)
3. Files without linear header → offer to sync via `history` mode
4. Linear-only issues with no local file → report

## Rules
- Always search Linear before creating (no duplicates)
- Priority from complexity: L→High, M→Medium, S→Low
- One line of output per action. No prose.
- No Linear project found → list available, ask which to use

Arguments: $ARGUMENTS
