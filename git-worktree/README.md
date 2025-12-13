# Git Worktree Plugin

A Claude Code plugin for git worktree management. Create worktrees, open them in new terminals with Claude Code, and clean up when done.

## Features

### `/wt-create`

- Create worktrees from existing or new branches
- Generate branch names from descriptions (auto-detected)
- Support branch prefixes (`feature/`, `bugfix/`, `hotfix/`, `release/`)
- Create from remote branches
- Auto-open new terminal with Claude Code

### `/wt-finish`

- Merge branch to main and clean up
- Create Pull Requests instead of direct merge
- Auto-push to remote
- Auto-close terminal after completion

### Parallel Tasks (Skill)

- Work on multiple tasks simultaneously
- Auto-creates worktrees and launches Claude sessions
- Maximum 3 parallel tasks
- Triggered by phrases like "in parallel", "at the same time"

## Supported Terminals

| Platform | Terminal | Status |
|----------|----------|--------|
| macOS | Terminal.app | ✅ Supported |
| macOS | iTerm2 | ✅ Supported |
| Linux | GNOME Terminal | ✅ Supported |
| Linux | Kitty | ✅ Supported |
| Linux | Konsole | ✅ Supported |
| Other | Generic | ⚠️ Manual instructions |

## Installation

```bash
# Add the marketplace
/plugin marketplace add himicoswilson/himi-claude-plugins

# Install the plugin
/plugin install git-worktree
```

## Usage

### Create a Worktree

```bash
# Checkout existing branch
/wt-create main

# Create new branch
/wt-create -b feature-login

# With prefix
/wt-create -p feature -b login        # feature/login
/wt-create -p bug -b fix-crash        # bugfix/fix-crash

# From description (auto-detected, confirms first)
/wt-create "add user authentication"

# With prefix from description
/wt-create -p feat "add login page"   # feature/add-login-page

# From remote branch
/wt-create -r origin/develop
```

### Finish a Worktree

```bash
# Default: merge -> remove worktree -> delete branch -> close terminal
/wt-finish

# Push to remote after merge
/wt-finish --push

# Create PR instead of merge
/wt-finish --pr

# Skip merge, only cleanup
/wt-finish --no-merge

# Force delete with uncommitted changes
/wt-finish --force
```

## Command Reference

### wt-create

| Option | Description |
|--------|-------------|
| `<branch>` | Checkout existing branch |
| `"<description>"` | Generate branch from description (auto-detected) |
| `-b <name>` | Create new branch with explicit name |
| `-p <type>` | Add prefix: `f`/`feature`, `b`/`bugfix`, `h`/`hotfix`, `r`/`release` |
| `-r <branch>` | Create from remote branch |

### wt-finish

| Option | Description |
|--------|-------------|
| (none) | Merge -> cleanup -> close terminal |
| `--push` | Push to remote after merge |
| `--pr` | Create PR instead of merge (requires `gh` CLI) |
| `--no-merge` | Skip merge, only cleanup |
| `--force` | Force delete with uncommitted changes |

## Requirements

- Git
- Claude Code
- GitHub CLI (`gh`) for `--pr` option

## License

MIT License - see [LICENSE](LICENSE) for details.
