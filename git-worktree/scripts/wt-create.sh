#!/bin/bash
#
# wt-create.sh - Create git worktree and open in new terminal with Claude
#
# Usage:
#   wt-create.sh <branch>                         - Checkout existing branch
#   wt-create.sh -b <new-branch>                  - Create new branch
#   wt-create.sh -d "<description>"               - Create branch from description
#   wt-create.sh -p <prefix> -b <name>            - Create with prefix (feature/bugfix/hotfix)
#   wt-create.sh -r <remote-branch>               - Create from remote branch
#   wt-create.sh <branch> <path>                  - Custom path

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

error() { echo -e "${RED}Error:${NC} $1" >&2; exit 1; }
info() { echo -e "${GREEN}Info:${NC} $1"; }
warn() { echo -e "${YELLOW}Warning:${NC} $1"; }

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

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    error "Not in a git repository"
fi

# Get repository root
REPO_ROOT=$(git rev-parse --show-toplevel)

# Parse arguments
CREATE_BRANCH=false
FROM_DESCRIPTION=false
FROM_REMOTE=false
BRANCH=""
WORKTREE_PATH=""
PREFIX=""
REMOTE_BRANCH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -b)
            CREATE_BRANCH=true
            shift
            [[ -z "$1" ]] && error "Branch name required after -b"
            BRANCH="$1"
            shift
            ;;
        -d|--desc)
            CREATE_BRANCH=true
            FROM_DESCRIPTION=true
            shift
            [[ -z "$1" ]] && error "Description required after -d"
            BRANCH=$(description_to_branch "$1")
            [[ -z "$BRANCH" ]] && error "Could not generate valid branch name from description"
            info "Generated branch name: $BRANCH"
            shift
            ;;
        -p|--prefix)
            shift
            [[ -z "$1" ]] && error "Prefix required after -p"
            case "$1" in
                feature|feat|f) PREFIX="feature/" ;;
                bugfix|bug|b) PREFIX="bugfix/" ;;
                hotfix|hot|h) PREFIX="hotfix/" ;;
                release|rel|r) PREFIX="release/" ;;
                *) PREFIX="$1/" ;;
            esac
            shift
            ;;
        -r|--remote)
            FROM_REMOTE=true
            shift
            [[ -z "$1" ]] && error "Remote branch required after -r"
            REMOTE_BRANCH="$1"
            shift
            ;;
        *)
            if [[ -z "$BRANCH" ]]; then
                BRANCH="$1"
            elif [[ -z "$WORKTREE_PATH" ]]; then
                WORKTREE_PATH="$1"
            else
                error "Too many arguments"
            fi
            shift
            ;;
    esac
done

# Handle remote branch
if [[ "$FROM_REMOTE" == true ]]; then
    [[ -z "$REMOTE_BRANCH" ]] && error "Remote branch is required with -r"

    # Fetch latest from remote
    info "Fetching from remote..."
    git fetch --all --prune

    # Check if remote branch exists
    if ! git rev-parse --verify "refs/remotes/$REMOTE_BRANCH" &>/dev/null; then
        # Try with origin/ prefix
        if git rev-parse --verify "refs/remotes/origin/$REMOTE_BRANCH" &>/dev/null; then
            REMOTE_BRANCH="origin/$REMOTE_BRANCH"
        else
            error "Remote branch '$REMOTE_BRANCH' does not exist"
        fi
    fi

    # Extract local branch name from remote
    if [[ -z "$BRANCH" ]]; then
        BRANCH="${REMOTE_BRANCH#*/}"  # Remove origin/ prefix
    fi
    CREATE_BRANCH=true
fi

# Validate branch name
[[ -z "$BRANCH" ]] && error "Branch name is required"

# Apply prefix if specified
if [[ -n "$PREFIX" ]]; then
    # Don't add prefix if branch already has one
    if [[ "$BRANCH" != */* ]]; then
        BRANCH="${PREFIX}${BRANCH}"
        info "Branch with prefix: $BRANCH"
    fi
fi

# Set default worktree path if not specified
if [[ -z "$WORKTREE_PATH" ]]; then
    # Use branch name without prefix for directory name
    DIR_NAME="${BRANCH##*/}"
    WORKTREE_PATH="$(dirname "$REPO_ROOT")/$DIR_NAME"
fi

# Expand ~ in path
WORKTREE_PATH="${WORKTREE_PATH/#\~/$HOME}"

# Make path absolute if relative
if [[ "$WORKTREE_PATH" != /* ]]; then
    WORKTREE_PATH="$REPO_ROOT/$WORKTREE_PATH"
fi

# Check if worktree path already exists
[[ -e "$WORKTREE_PATH" ]] && error "Path already exists: $WORKTREE_PATH"

# Check if branch exists (when not creating new)
if [[ "$CREATE_BRANCH" == false ]]; then
    if ! git rev-parse --verify "$BRANCH" &>/dev/null; then
        error "Branch '$BRANCH' does not exist. Use -b to create a new branch."
    fi
fi

# Create the worktree
info "Creating worktree at: $WORKTREE_PATH"

if [[ "$FROM_REMOTE" == true ]]; then
    # Create from remote branch
    git worktree add -b "$BRANCH" "$WORKTREE_PATH" "$REMOTE_BRANCH"
    info "Created from remote: $REMOTE_BRANCH"
elif [[ "$CREATE_BRANCH" == true ]]; then
    git worktree add -b "$BRANCH" "$WORKTREE_PATH"
else
    git worktree add "$WORKTREE_PATH" "$BRANCH"
fi

info "Worktree created successfully"

# Output worktree info
echo ""
echo "Worktree location: $WORKTREE_PATH"
echo "Branch: $BRANCH"
[[ "$FROM_REMOTE" == true ]] && echo "Tracking: $REMOTE_BRANCH"

# Try to open new Terminal.app window and run claude
info "Opening new terminal with Claude Code..."

if open -a Terminal "$WORKTREE_PATH" 2>/dev/null; then
    sleep 1
    if osascript -e "tell application \"Terminal\" to do script \"claude\" in front window" 2>/dev/null; then
        info "Done! A new Terminal window should open with Claude Code in the worktree."
    else
        warn "Terminal opened but couldn't run claude automatically."
        echo ""
        echo "Run this command in the new terminal:"
        echo "  claude"
    fi
else
    warn "Could not open Terminal.app (possibly running in sandbox mode)."
    echo ""
    echo "Run these commands manually in a new terminal:"
    echo ""
    echo "  cd '$WORKTREE_PATH' && claude"
    echo ""
fi
