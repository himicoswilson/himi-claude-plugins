#!/bin/bash
#
# linux-kitty.sh - Kitty terminal adapter for Linux/macOS
#
# Functions:
#   adapter_open_terminal <path> <command>  - Open new terminal window
#   adapter_close_terminal                  - Close current terminal window

# Open new Kitty window and run command
# Args: $1 = path to cd into, $2 = command to run
adapter_open_terminal() {
    local path="$1"
    local command="${2:-}"

    if ! command -v kitty &>/dev/null; then
        return 1
    fi

    if [[ -n "$command" ]]; then
        # Launch new Kitty window with command
        kitty --detach --directory="$path" bash -c "$command; exec bash" 2>/dev/null
    else
        kitty --detach --directory="$path" 2>/dev/null
    fi

    return 0
}

# Close current terminal
adapter_close_terminal() {
    local delay="${1:-3}"

    echo ""
    echo "Closing this terminal in ${delay} seconds... (Ctrl+C to cancel)"
    sleep "$delay"

    # Try kitty remote control first
    if [[ -n "$KITTY_WINDOW_ID" ]]; then
        kitty @ close-window --self 2>/dev/null && return 0
    fi

    exit 0
}

# Get terminal name for display
adapter_name() {
    echo "Kitty"
}
