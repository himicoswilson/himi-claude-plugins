#!/bin/bash
#
# linux-konsole.sh - Konsole (KDE) terminal adapter for Linux
#
# Functions:
#   adapter_open_terminal <path> <command>  - Open new terminal window
#   adapter_close_terminal                  - Close current terminal window

# Open new Konsole window and run command
# Args: $1 = path to cd into, $2 = command to run
adapter_open_terminal() {
    local path="$1"
    local command="${2:-}"

    if ! command -v konsole &>/dev/null; then
        return 1
    fi

    if [[ -n "$command" ]]; then
        konsole --new-tab --workdir "$path" -e bash -c "$command; exec bash" 2>/dev/null &
    else
        konsole --new-tab --workdir "$path" 2>/dev/null &
    fi

    return 0
}

# Close current terminal
adapter_close_terminal() {
    local delay="${1:-3}"

    echo ""
    echo "Closing this terminal in ${delay} seconds... (Ctrl+C to cancel)"
    sleep "$delay"
    exit 0
}

# Get terminal name for display
adapter_name() {
    echo "Konsole"
}
