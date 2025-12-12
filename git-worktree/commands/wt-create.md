---
name: wt-create
description: Create a git worktree and open it in a new terminal with Claude Code
argument-hint: "[ <branch> | -b <name> | -d <desc> | -p <prefix> | -r <remote> ]"
allowed-tools: Bash, AskUserQuestion
---

# Git Worktree Create

Create a git worktree and open Terminal.app with Claude Code.

## Modes

| Mode | Syntax | Behavior |
|------|--------|----------|
| Checkout | `<branch>` | Switch to existing branch |
| Create | `-b <name>` | Create new branch |
| Describe | `-d <desc>` | Generate branch from description, **confirm first** |
| Prefix | `-p <type> -b <name>` | Create with prefix (feature/bugfix/hotfix) |
| Remote | `-r <remote-branch>` | Create from remote branch |

## Options

| Flag | Short | Description |
|------|-------|-------------|
| `-b <name>` | | Create new branch with name |
| `-d <desc>` | `--desc` | Generate branch name from description |
| `-p <type>` | `--prefix` | Add prefix: `f`/`feature`, `b`/`bugfix`, `h`/`hotfix`, `r`/`release` |
| `-r <branch>` | `--remote` | Create from remote branch (auto-fetches) |

## Rules

1. **Plan mode active** → Do NOT execute. Only discuss.
2. **-d mode** → Must confirm with user before executing.
3. **Other modes** → Execute immediately.

## Examples

| Input | Branch Created |
|-------|----------------|
| `-b login` | `login` |
| `-p f -b login` | `feature/login` |
| `-p bug -b fix-crash` | `bugfix/fix-crash` |
| `-d "add user auth"` | `add-user-auth` (confirm first) |
| `-p feat -d "add login"` | `feature/add-login` (confirm first) |
| `-r origin/develop` | `develop` (tracks remote) |

## Execution

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/wt-create.sh <args>
```
