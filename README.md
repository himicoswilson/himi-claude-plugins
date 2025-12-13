# Claude Code Plugin Marketplace

A plugin marketplace for Claude Code by himicoswilson.

## Available Plugins

| Plugin | Description |
|--------|-------------|
| [git-worktree](./git-worktree/) | Manage git worktrees with Claude Code |

## Installation

```bash
# Add the marketplace
/plugin marketplace add himicoswilson/himi-claude-plugins

# Install plugin
/plugin install git-worktree
```

## Repository Structure

```
.
├── .claude-plugin/
│   └── marketplace.json    # Marketplace definition
└── git-worktree/           # Git worktree plugin
    ├── .claude-plugin/
    │   └── plugin.json     # Plugin manifest
    ├── commands/           # Slash commands
    │   ├── wt-create.md
    │   └── wt-finish.md
    ├── scripts/            # Shell scripts
    │   ├── wt-create.sh
    │   ├── wt-finish.sh
    │   ├── wt-parallel.sh
    │   └── lib/            # Shared libraries
    │       ├── common.sh
    │       ├── terminal.sh
    │       ├── detect-terminal.sh
    │       └── adapters/   # Terminal adapters
    ├── skills/             # Agent skills
    │   └── parallel-tasks/
    │       └── SKILL.md
    ├── LICENSE
    └── README.md
```

## License

MIT License - see individual plugin directories for details.

## Author

**himicoswilson**
