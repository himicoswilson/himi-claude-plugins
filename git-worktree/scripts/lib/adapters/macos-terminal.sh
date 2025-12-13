#!/bin/bash
#
# macos-terminal.sh - Terminal.app adapter for macOS
#
# Functions:
#   adapter_open_terminal <path> <command>  - Open new terminal window
#   adapter_close_terminal                  - Close current terminal window

# Open new Terminal.app window and run command
# Args: $1 = path to cd into, $2 = command to run
adapter_open_terminal() {
    local path="$1"
    local command="${2:-}"

    # Try to open Terminal.app
    if ! open -a Terminal "$path" 2>/dev/null; then
        return 1
    fi

    sleep 1

    # Run command if provided
    if [[ -n "$command" ]]; then
        local escaped_command
        escaped_command="${command//\\/\\\\}"
        escaped_command="${escaped_command//\"/\\\"}"

        if ! osascript -e "tell application \"Terminal\" to do script \"$escaped_command\" in front window" 2>/dev/null; then
            return 2  # Terminal opened but command failed
        fi
    fi

    return 0
}

# Close current Terminal.app window
adapter_close_terminal() {
    local delay="${1:-3}"

    echo ""
    echo "Closing this terminal in ${delay} seconds... (Ctrl+C to cancel)"
    sleep "$delay"
    osascript -e 'tell application "Terminal" to close front window' 2>/dev/null || true
}

# Get terminal name for display
adapter_name() {
    echo "Terminal.app"
}
