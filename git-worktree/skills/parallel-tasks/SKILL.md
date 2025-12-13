---
name: parallel-tasks
description: |
  Automatically create multiple git worktrees and launch parallel Claude sessions.
  Use when user wants to work on multiple tasks simultaneously.
  Triggers: "parallel tasks", "work on multiple things", "split into branches",
  "do simultaneously", "at the same time", "in parallel", "multiple tasks".
  Maximum 3 parallel tasks allowed.
allowed-tools: Bash, AskUserQuestion
---

# Parallel Tasks

Create multiple git worktrees for parallel task execution, each with its own Claude session.

## Workflow

### Step 1: Parse User Intent

When you detect the user wants to work on multiple tasks simultaneously:
1. Identify distinct tasks from their request
2. Generate branch names for each task using the naming convention below
3. Draft detailed prompts for each Claude session

### Step 2: Confirm with User (REQUIRED)

**You MUST use AskUserQuestion to confirm before creating anything.**

Present the breakdown to the user:
- Task descriptions
- Generated branch names (with prefix options)
- Proposed initial prompts for each Claude session

Example confirmation format:
```
Detected 2 parallel tasks:

Task 1: User Authentication
  Branch: feature/user-auth
  Prompt: "Implement user authentication including login, registration..."

Task 2: Payment Integration
  Branch: feature/payment
  Prompt: "Implement payment functionality with Stripe API..."
```

### Step 3: Execute Creation

After user confirmation, call the script:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/wt-parallel.sh" \
  --branches "feature/user-auth|feature/payment" \
  --prompts "Implement user authentication...|Implement payment..."
```

## Branch Naming Convention

Convert task descriptions to branch names:
- Lowercase, remove special characters
- Replace spaces with hyphens
- Maximum 50 characters
- Deduplicate consecutive hyphens

Prefix options:
- `feature/` - New features (default)
- `bugfix/` - Bug fixes
- `hotfix/` - Urgent fixes
- `release/` - Release preparation

## Constraints

- **Maximum 3 tasks** - Prevents resource exhaustion and context switching overhead
- **Requires confirmation** - Never create worktrees without explicit user approval
- **macOS only** - Uses Terminal.app and AppleScript

## Error Handling

If worktree creation fails for one task:
1. Log the error
2. Continue with remaining tasks
3. Report which tasks succeeded/failed at the end

## Examples

### Example 1: Feature Development

User: "I want to implement user authentication and product search at the same time"

Response:
1. Parse: 2 tasks - user auth, product search
2. Generate branches: `feature/user-auth`, `feature/product-search`
3. Ask user to confirm branches and prompts
4. After confirmation, execute creation

### Example 2: Bug Fixes

User: "Help me fix the login bug and the cart calculation issue in parallel"

Response:
1. Parse: 2 tasks - login bug, cart calculation
2. Generate branches: `bugfix/login`, `bugfix/cart-calculation`
3. Ask user to confirm
4. Execute after approval
