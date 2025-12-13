# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Claude Code plugin marketplace (`himi-claude-plugins`) containing the **git-worktree** plugin. The plugin provides slash commands for managing Git worktrees with Terminal.app integration on macOS.

## Architecture

```
himi-claude-plugins/
├── .claude-plugin/marketplace.json    # Marketplace definition
└── git-worktree/                      # Plugin package
    ├── .claude-plugin/plugin.json     # Plugin manifest
    ├── commands/                      # Slash command definitions (.md)
    │   ├── wt-create.md               # Create worktree command spec
    │   └── wt-finish.md               # Finish worktree command spec
    ├── scripts/                       # Implementation (Bash)
    │   ├── wt-create.sh               # Worktree creation logic
    │   ├── wt-finish.sh               # Merge/cleanup logic
    │   └── wt-parallel.sh             # Parallel worktree creation
    └── skills/                        # Agent Skills
        └── parallel-tasks/SKILL.md    # Auto-detect parallel task intent
```

**Key Design**: Command `.md` files define the Claude Code interface (allowed tools, argument parsing), while `.sh` scripts contain the implementation. Skills are model-invoked capabilities that Claude automatically uses when relevant.

## Development

**No build system** - pure shell scripts with no compilation.

**Testing plugins locally**:
```bash
# The plugin is already available as slash commands when Claude Code loads this repo
/git-worktree:wt-create -b test-branch
/git-worktree:wt-finish --no-merge
```

**Shell script validation**:
```bash
bash -n git-worktree/scripts/wt-create.sh  # Syntax check
bash -n git-worktree/scripts/wt-finish.sh
bash -n git-worktree/scripts/wt-parallel.sh
```

## Code Conventions

### Shell Scripts
- Use `set -e` for strict error handling
- Color output functions: `error()` (red), `info()` (green), `warn()` (yellow)
- Validate git state before operations
- Auto-detect main/master branch dynamically
- Expand paths (~ and relative to absolute)

### Branch Naming
Descriptions are converted to branch names via:
- Lowercase, remove non-alphanumeric, spaces to hyphens
- Deduplicate hyphens, max 50 chars
- Optional prefix: `feature/`, `bugfix/`, `hotfix/`, `release/`

### Command Files (.md)
- Specify allowed tools in YAML frontmatter style
- Document all argument modes and flags
- Include usage examples and error handling instructions

## Platform Requirements

- **macOS** (Terminal.app integration via AppleScript)
- **Git** with worktree support
- **GitHub CLI** (`gh`) - optional, only for `--pr` flag

## Versioning

Follow [Semantic Versioning](https://semver.org/):
- **MAJOR** (x.0.0): Breaking changes
- **MINOR** (0.x.0): New features, backward compatible
- **PATCH** (0.0.x): Bug fixes, backward compatible

Update version in:
- `git-worktree/.claude-plugin/plugin.json` - plugin version
- `.claude-plugin/marketplace.json` - marketplace and plugin entry versions
