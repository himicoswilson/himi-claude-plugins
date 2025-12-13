#!/bin/bash
#
# wt-parallel.sh - Create multiple git worktrees and launch parallel Claude sessions
#
# Usage:
#   wt-parallel.sh --branches "branch1|branch2|branch3" --prompts "prompt1|prompt2|prompt3"
#
# Maximum 3 parallel tasks supported.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

error() { echo -e "${RED}Error:${NC} $1" >&2; }
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

# Escape prompt for shell and AppleScript
escape_prompt() {
    local prompt="$1"
    # Escape backslashes, double quotes, and single quotes for shell
    prompt="${prompt//\\/\\\\}"
    prompt="${prompt//\"/\\\"}"
    echo "$prompt"
}

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    error "Not in a git repository"
    exit 1
fi

# Get repository root and name
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$REPO_ROOT")

# Parse arguments
BRANCHES=""
PROMPTS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --branches)
            shift
            [[ -z "$1" ]] && { error "Branches required after --branches"; exit 1; }
            BRANCHES="$1"
            shift
            ;;
        --prompts)
            shift
            [[ -z "$1" ]] && { error "Prompts required after --prompts"; exit 1; }
            PROMPTS="$1"
            shift
            ;;
        *)
            error "Unknown argument: $1"
            exit 1
            ;;
    esac
done

# Validate required arguments
[[ -z "$BRANCHES" ]] && { error "--branches is required"; exit 1; }
[[ -z "$PROMPTS" ]] && { error "--prompts is required"; exit 1; }

# Parse pipe-separated values into arrays
IFS='|' read -ra BRANCH_ARRAY <<< "$BRANCHES"
IFS='|' read -ra PROMPT_ARRAY <<< "$PROMPTS"

# Validate array lengths match
if [[ ${#BRANCH_ARRAY[@]} -ne ${#PROMPT_ARRAY[@]} ]]; then
    error "Number of branches (${#BRANCH_ARRAY[@]}) must match number of prompts (${#PROMPT_ARRAY[@]})"
    exit 1
fi

# Validate maximum 3 tasks
TASK_COUNT=${#BRANCH_ARRAY[@]}
if [[ $TASK_COUNT -gt 3 ]]; then
    error "Maximum 3 parallel tasks allowed, got $TASK_COUNT"
    exit 1
fi

if [[ $TASK_COUNT -lt 1 ]]; then
    error "At least one task is required"
    exit 1
fi

info "Creating $TASK_COUNT parallel worktrees..."
echo ""

# Track results
SUCCEEDED=()
FAILED=()

# Create worktrees and launch Claude sessions
for i in "${!BRANCH_ARRAY[@]}"; do
    BRANCH="${BRANCH_ARRAY[$i]}"
    PROMPT="${PROMPT_ARRAY[$i]}"
    TASK_NUM=$((i + 1))

    task_info "$TASK_NUM" "Branch: $BRANCH"

    # Determine worktree path
    DIR_NAME="${BRANCH##*/}"  # Remove prefix (feature/, bugfix/, etc.)
    WORKTREE_PATH="$(dirname "$REPO_ROOT")/$DIR_NAME"

    # Check if path already exists
    if [[ -e "$WORKTREE_PATH" ]]; then
        error "  Path already exists: $WORKTREE_PATH"
        FAILED+=("$BRANCH (path exists)")
        continue
    fi

    # Check if branch already exists
    if git rev-parse --verify "$BRANCH" &>/dev/null; then
        error "  Branch already exists: $BRANCH"
        FAILED+=("$BRANCH (branch exists)")
        continue
    fi

    # Create the worktree
    if ! git worktree add -b "$BRANCH" "$WORKTREE_PATH" 2>&1; then
        error "  Failed to create worktree for $BRANCH"
        FAILED+=("$BRANCH (worktree creation failed)")
        continue
    fi

    info "  Worktree created at: $WORKTREE_PATH"

    # Escape prompt for AppleScript
    ESCAPED_PROMPT=$(escape_prompt "$PROMPT")

    # Open new Terminal window and run claude with prompt
    if osascript <<EOF 2>/dev/null
tell application "Terminal"
    do script "cd '$WORKTREE_PATH' && claude \"$ESCAPED_PROMPT\""
    activate
end tell
EOF
    then
        info "  Terminal launched with Claude session"
        SUCCEEDED+=("$BRANCH")
    else
        warn "  Worktree created but couldn't launch Terminal automatically"
        echo "    Run manually: cd '$WORKTREE_PATH' && claude \"$ESCAPED_PROMPT\""
        SUCCEEDED+=("$BRANCH (manual launch needed)")
    fi

    echo ""

    # Small delay between terminal launches to avoid race conditions
    sleep 0.5
done

# Summary
echo "========================================"
info "Summary:"
echo ""

if [[ ${#SUCCEEDED[@]} -gt 0 ]]; then
    echo -e "${GREEN}Succeeded (${#SUCCEEDED[@]}):${NC}"
    for s in "${SUCCEEDED[@]}"; do
        echo "  ✓ $s"
    done
fi

if [[ ${#FAILED[@]} -gt 0 ]]; then
    echo ""
    echo -e "${RED}Failed (${#FAILED[@]}):${NC}"
    for f in "${FAILED[@]}"; do
        echo "  ✗ $f"
    done
fi

echo ""
echo "========================================"

# Exit with error if any failed
if [[ ${#FAILED[@]} -gt 0 ]]; then
    exit 1
fi
