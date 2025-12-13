#!/bin/bash
#
# wt-finish.sh - Merge branch to main, remove worktree and delete branch
#
# Usage:
#   wt-finish.sh                - Merge, remove worktree, delete branch
#   wt-finish.sh --no-merge     - Skip merge, only cleanup
#   wt-finish.sh --push         - Push to remote after merge
#   wt-finish.sh --pr           - Create PR instead of merge (requires gh cli)
#   wt-finish.sh --force        - Force delete with unmerged changes

set -e

# Get script directory and source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/terminal.sh"

# Parse arguments
NO_MERGE=false
FORCE=false
PUSH=false
CREATE_PR=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-merge) NO_MERGE=true; shift ;;
        --force) FORCE=true; shift ;;
        --push) PUSH=true; shift ;;
        --pr) CREATE_PR=true; shift ;;
        *) error "Unknown option: $1" ;;
    esac
done

# Check if in a worktree
WORKTREE_PATH=$(pwd)
WORKTREE_LIST=$(git worktree list 2>/dev/null) || error "Not in a git repository"

MAIN_REPO=$(echo "$WORKTREE_LIST" | head -1 | awk '{print $1}')

if [[ "$WORKTREE_PATH" == "$MAIN_REPO" ]]; then
    error "You are in the main repository, not a worktree"
fi

# Get current branch
BRANCH=$(git branch --show-current)
if [[ -z "$BRANCH" ]]; then
    error "Could not determine current branch"
fi

info "Current branch: $BRANCH"
info "Worktree path: $WORKTREE_PATH"
info "Main repo: $MAIN_REPO"

# Check for uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
    if [[ "$FORCE" == false ]]; then
        error "Uncommitted changes exist. Commit or stash them first, or use --force"
    else
        warn "Uncommitted changes will be discarded"
    fi
fi

# Determine main branch name
cd "$MAIN_REPO"
MAIN_BRANCH=$(get_main_branch "$MAIN_REPO")

info "Main branch: $MAIN_BRANCH"

# Handle PR creation
if [[ "$CREATE_PR" == true ]]; then
    # Check if gh cli is available
    if ! command -v gh &>/dev/null; then
        error "GitHub CLI (gh) is required for --pr option. Install it with: brew install gh"
    fi

    # Push branch to remote first
    info "Pushing branch to remote..."
    cd "$WORKTREE_PATH"
    git push -u origin "$BRANCH" 2>/dev/null || git push origin "$BRANCH"

    # Create PR
    info "Creating Pull Request..."
    PR_URL=$(gh pr create --fill --head "$BRANCH" --base "$MAIN_BRANCH" 2>&1) || {
        # PR might already exist
        PR_URL=$(gh pr view "$BRANCH" --json url -q .url 2>/dev/null) || error "Failed to create PR"
    }

    info "Pull Request: $PR_URL"
    echo ""
    warn "PR created. Worktree NOT removed (you may need to make changes)."
    echo "After PR is merged, run: wt-finish --no-merge"
    exit 0
fi

# Merge if not skipped
if [[ "$NO_MERGE" == false ]]; then
    info "Checking out $MAIN_BRANCH..."
    git checkout "$MAIN_BRANCH"

    info "Merging $BRANCH into $MAIN_BRANCH..."
    if ! git merge "$BRANCH" --no-edit; then
        error "Merge failed. Resolve conflicts manually"
    fi
    info "Merge successful"

    # Push if requested
    if [[ "$PUSH" == true ]]; then
        info "Pushing to remote..."
        git push origin "$MAIN_BRANCH"
        info "Pushed successfully"
    fi
fi

# Remove worktree
info "Removing worktree at $WORKTREE_PATH..."
if [[ "$FORCE" == true ]]; then
    git worktree remove "$WORKTREE_PATH" --force
else
    git worktree remove "$WORKTREE_PATH"
fi
info "Worktree removed"

# Delete branch
info "Deleting branch $BRANCH..."
if [[ "$FORCE" == true ]]; then
    git branch -D "$BRANCH"
else
    git branch -d "$BRANCH"
fi

# Delete remote branch if it exists
if git ls-remote --heads origin "$BRANCH" | grep -q "$BRANCH"; then
    info "Deleting remote branch..."
    git push origin --delete "$BRANCH" 2>/dev/null || warn "Could not delete remote branch"
fi

info "Branch deleted"

echo ""
info "Done! Worktree cleaned up successfully."
echo "  Merged: $BRANCH → $MAIN_BRANCH"
[[ "$PUSH" == true ]] && echo "  Pushed: $MAIN_BRANCH → origin"
echo "  Removed: $WORKTREE_PATH"
echo "  Deleted: branch $BRANCH"

# Auto-close terminal
close_terminal 3
