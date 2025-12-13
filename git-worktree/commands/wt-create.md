---
name: wt-create
description: Create a git worktree and open it in a new terminal with Claude Code
argument-hint: "[ <branch> | <description> | -b <name> | -p <prefix> | -r <remote> ]"
allowed-tools: Bash, AskUserQuestion
---

# Git Worktree Create

Create a git worktree and open Terminal.app with Claude Code.

## Rules

1. **Sandbox mode** → Stop immediately. Do not execute.
2. **Description input** → Confirm generated branch name before executing.
3. **Other modes** → Execute immediately.

## Modes

| Mode | Syntax | Behavior |
|------|--------|----------|
| Checkout | `<branch>` | Switch to existing branch |
| Create | `-b <name>` | Create new branch |
| Describe | `"<description>"` | Generate branch from description, **confirm first** |
| Prefix | `-p <type> -b <name>` | Create with prefix |
| Remote | `-r <remote-branch>` | Create from remote branch |

## Options

| Flag | Description |
|------|-------------|
| `-b <name>` | Create new branch with name |
| `-p <type>` | Add prefix: `f`/`feature`, `b`/`bugfix`, `h`/`hotfix`, `r`/`release` |
| `-r <branch>` | Create from remote branch (auto-fetches) |

## Examples

| Input | Branch Created |
|-------|----------------|
| `main` | checkout `main` |
| `-b login` | `login` |
| `-p f -b login` | `feature/login` |
| `"add user auth"` | `add-user-auth` (confirm first) |
| `-p feat "add login"` | `feature/add-login` (confirm first) |
| `-r origin/develop` | `develop` (tracks remote) |

## Execution

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/wt-create.sh <args>
```
