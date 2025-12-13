#!/bin/bash
#
# wt-parallel.sh - Create multiple git worktrees and launch parallel Claude sessions
#
# Usage:
#   wt-parallel.sh --branches "branch1|branch2|branch3" --prompts "prompt1|prompt2|prompt3"
#
# Maximum 3 parallel tasks supported.

set -e

# Get script directory and source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/terminal.sh"

# Check if we're in a git repository
check_git_repo

# Get repository root and name
REPO_ROOT=$(get_repo_root)
REPO_NAME=$(basename "$REPO_ROOT")

# Parse arguments
BRANCHES=""
PROMPTS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --branches)
            shift
            [[ -z "$1" ]] && error "Branches required after --branches"
            BRANCHES="$1"
            shift
            ;;
        --prompts)
            shift
            [[ -z "$1" ]] && error "Prompts required after --prompts"
            PROMPTS="$1"
            shift
            ;;
        *)
            error "Unknown argument: $1"
            ;;
    esac
done

# Validate required arguments
[[ -z "$BRANCHES" ]] && error "--branches is required"
[[ -z "$PROMPTS" ]] && error "--prompts is required"

# Parse pipe-separated values into arrays
IFS='|' read -ra BRANCH_ARRAY <<< "$BRANCHES"
IFS='|' read -ra PROMPT_ARRAY <<< "$PROMPTS"

# Validate array lengths match
if [[ ${#BRANCH_ARRAY[@]} -ne ${#PROMPT_ARRAY[@]} ]]; then
    error "Number of branches (${#BRANCH_ARRAY[@]}) must match number of prompts (${#PROMPT_ARRAY[@]})"
fi

# Validate maximum 3 tasks
TASK_COUNT=${#BRANCH_ARRAY[@]}
if [[ $TASK_COUNT -gt 3 ]]; then
    error "Maximum 3 parallel tasks allowed, got $TASK_COUNT"
fi

if [[ $TASK_COUNT -lt 1 ]]; then
    error "At least one task is required"
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
        echo -e "${RED}Error:${NC}   Path already exists: $WORKTREE_PATH" >&2
        FAILED+=("$BRANCH (path exists)")
        continue
    fi

    # Check if branch already exists
    if git rev-parse --verify "$BRANCH" &>/dev/null; then
        echo -e "${RED}Error:${NC}   Branch already exists: $BRANCH" >&2
        FAILED+=("$BRANCH (branch exists)")
        continue
    fi

    # Create the worktree
    if ! git worktree add -b "$BRANCH" "$WORKTREE_PATH" 2>&1; then
        echo -e "${RED}Error:${NC}   Failed to create worktree for $BRANCH" >&2
        FAILED+=("$BRANCH (worktree creation failed)")
        continue
    fi

    info "  Worktree created at: $WORKTREE_PATH"

    # Open new terminal with claude and prompt
    ESCAPED_PROMPT=$(escape_for_shell "$PROMPT")

    if open_new_terminal "$WORKTREE_PATH" "claude \"$ESCAPED_PROMPT\""; then
        info "  Terminal launched with Claude session"
        SUCCEEDED+=("$BRANCH")
    else
        warn "  Worktree created but couldn't launch terminal automatically"
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
