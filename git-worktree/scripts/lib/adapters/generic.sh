#!/bin/bash
#
# generic.sh - Generic fallback adapter (prints instructions)
#
# Functions:
#   adapter_open_terminal <path> <command>  - Print manual instructions
#   adapter_close_terminal                  - No-op

# Print manual instructions (cannot open terminal automatically)
# Args: $1 = path to cd into, $2 = command to run
adapter_open_terminal() {
    local path="$1"
    local command="${2:-}"

    echo ""
    echo "Could not open terminal automatically."
    echo ""
    echo "Run these commands manually in a new terminal:"
    echo ""
    if [[ -n "$command" ]]; then
        echo "  cd '$path' && $command"
    else
        echo "  cd '$path'"
    fi
    echo ""

    return 1  # Indicate manual action needed
}

# No-op for generic terminal
adapter_close_terminal() {
    echo ""
    echo "Please close this terminal window manually."
}

# Get terminal name for display
adapter_name() {
    echo "Generic Terminal"
}
