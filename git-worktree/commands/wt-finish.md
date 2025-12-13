---
name: wt-finish
description: Merge current branch to main, delete worktree and branch
argument-hint: "[ --push | --pr | --no-merge | --force ]"
allowed-tools: Bash, AskUserQuestion
---

# Worktree Finish

Complete the current worktree task: merge to main, remove worktree, delete branch.

## Rules

1. **Sandbox mode** → Stop immediately. Do not execute.
2. **Always confirm** before executing.
3. Check for uncommitted changes before proceeding.

## Options

| Flag | Description |
|------|-------------|
| (none) | Merge → Remove worktree → Delete branch → Close terminal |
| `--push` | Push to remote after merge |
| `--pr` | Create PR instead of merge (keeps worktree) |
| `--no-merge` | Skip merge, only cleanup |
| `--force` | Force delete with unmerged changes |

## Flows

### Default
Merge → Remove worktree → Delete branch → Close terminal (3s delay)

### `--pr`
Push → Create PR via `gh` → Keep worktree (for review changes)
After PR merged: `wt-finish --no-merge`

### `--push`
Merge → Push main → Remove worktree → Close terminal

## Prerequisites

- `--pr` requires GitHub CLI: `brew install gh`

## Execution

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/wt-finish.sh [options]
```
