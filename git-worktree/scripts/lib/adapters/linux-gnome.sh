#!/bin/bash
#
# linux-gnome.sh - GNOME Terminal adapter for Linux
#
# Functions:
#   adapter_open_terminal <path> <command>  - Open new terminal window
#   adapter_close_terminal                  - Close current terminal window

# Open new GNOME Terminal window and run command
# Args: $1 = path to cd into, $2 = command to run
adapter_open_terminal() {
    local path="$1"
    local command="${2:-}"

    if ! command -v gnome-terminal &>/dev/null; then
        return 1
    fi

    if [[ -n "$command" ]]; then
        # Use -- to pass command, bash -c to run and keep alive
        gnome-terminal --working-directory="$path" -- bash -c "$command; exec bash" 2>/dev/null &
    else
        gnome-terminal --working-directory="$path" 2>/dev/null &
    fi

    return 0
}

# Close current terminal (send exit)
adapter_close_terminal() {
    local delay="${1:-3}"

    echo ""
    echo "Closing this terminal in ${delay} seconds... (Ctrl+C to cancel)"
    sleep "$delay"
    exit 0
}

# Get terminal name for display
adapter_name() {
    echo "GNOME Terminal"
}
