#!/bin/bash
#
# macos-iterm.sh - iTerm2 adapter for macOS
#
# Functions:
#   adapter_open_terminal <path> <command>  - Open new terminal window
#   adapter_close_terminal                  - Close current terminal window

# Open new iTerm2 window and run command
# Args: $1 = path to cd into, $2 = command to run
adapter_open_terminal() {
    local path="$1"
    local command="${2:-}"

    local escaped_path="${path//\\/\\\\}"
    escaped_path="${escaped_path//\"/\\\"}"

    local escaped_command=""
    if [[ -n "$command" ]]; then
        escaped_command="${command//\\/\\\\}"
        escaped_command="${escaped_command//\"/\\\"}"
    fi

    local script
    if [[ -n "$command" ]]; then
        script="
tell application \"iTerm\"
    activate
    create window with default profile
    tell current session of current window
        write text \"cd '$escaped_path' && $escaped_command\"
    end tell
end tell"
    else
        script="
tell application \"iTerm\"
    activate
    create window with default profile
    tell current session of current window
        write text \"cd '$escaped_path'\"
    end tell
end tell"
    fi

    if ! osascript -e "$script" 2>/dev/null; then
        return 1
    fi

    return 0
}

# Close current iTerm2 window/tab
adapter_close_terminal() {
    local delay="${1:-3}"

    echo ""
    echo "Closing this terminal in ${delay} seconds... (Ctrl+C to cancel)"
    sleep "$delay"
    osascript -e 'tell application "iTerm" to close current session of current window' 2>/dev/null || true
}

# Get terminal name for display
adapter_name() {
    echo "iTerm2"
}
