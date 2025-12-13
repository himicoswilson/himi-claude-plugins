#!/bin/bash
#
# common.sh - Shared functions for git-worktree scripts
#
# Usage: source "${SCRIPT_DIR}/lib/common.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Output functions
error() { echo -e "${RED}Error:${NC} $1" >&2; exit 1; }
info() { echo -e "${GREEN}Info:${NC} $1"; }
warn() { echo -e "${YELLOW}Warning:${NC} $1"; }
task_info() { echo -e "${CYAN}Task $1:${NC} $2"; }

# Convert description to valid branch name
description_to_branch() {
    local desc="$1"
    echo "$desc" | \
        tr '[:upper:]' '[:lower:]' | \
        sed 's/[^a-z0-9 -]//g' | \
        sed 's/  */ /g' | \
        sed 's/ /-/g' | \
        sed 's/--*/-/g' | \
        sed 's/^-//' | \
        sed 's/-$//' | \
        cut -c1-50
}

# Check if input looks like a description (contains spaces)
is_description() {
    local input="$1"
    [[ "$input" == *" "* ]] && return 0
    return 1
}

# Check if we're in a git repository
check_git_repo() {
    git rev-parse --is-inside-work-tree &>/dev/null || error "Not in a git repository"
}

# Get repository root
get_repo_root() {
    git rev-parse --show-toplevel
}

# Get main branch name (main or master)
get_main_branch() {
    local repo_path="${1:-.}"
    cd "$repo_path"
    if git show-ref --verify --quiet refs/heads/main; then
        echo "main"
    elif git show-ref --verify --quiet refs/heads/master; then
        echo "master"
    else
        error "Could not find main or master branch"
    fi
}

# Escape string for shell/AppleScript
escape_for_shell() {
    local str="$1"
    str="${str//\\/\\\\}"
    str="${str//\"/\\\"}"
    echo "$str"
}
