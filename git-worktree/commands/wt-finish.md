---
name: wt-finish
description: Merge current branch to main, delete worktree and branch
argument-hint: "[ --push | --pr | --no-merge | --force ]"
allowed-tools: Bash, AskUserQuestion
---

# Worktree Finish

Complete the current worktree task: merge to main, remove worktree, delete branch.

## Options

| Flag | Description |
|------|-------------|
| (none) | Merge → Remove worktree → Delete branch → Close terminal |
| `--push` | Push to remote after merge |
| `--pr` | Create PR instead of merge (keeps worktree for changes) |
| `--no-merge` | Skip merge, only remove worktree and branch |
| `--force` | Force delete even with unmerged changes |

## Flows

### Default Flow
1. Merge branch into main/master
2. Remove worktree directory
3. Delete local branch
4. Delete remote branch (if exists)
5. Close terminal (3s delay)

### PR Flow (`--pr`)
1. Push branch to remote
2. Create Pull Request via `gh` CLI
3. **Keep worktree** (may need changes after review)
4. After PR merged, run: `wt-finish --no-merge`

### Push Flow (`--push`)
1. Merge branch into main/master
2. Push main to origin
3. Remove worktree and branch
4. Close terminal

## Rules

1. **Plan mode** → Do NOT execute. Only discuss.
2. **Always confirm** before executing.
3. Check for uncommitted changes before proceeding.

## Prerequisites

- `--pr` requires GitHub CLI: `brew install gh`

## Execution

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/wt-finish.sh [options]
```

## Errors

- Not in a worktree
- Uncommitted changes exist
- Merge conflicts
- Branch has unmerged commits (use --force)
