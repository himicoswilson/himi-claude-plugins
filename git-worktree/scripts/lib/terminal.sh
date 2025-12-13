#!/bin/bash
#
# terminal.sh - Unified terminal operations
#
# Usage: source "${SCRIPT_DIR}/lib/terminal.sh"
#
# Functions:
#   open_new_terminal <path> [command]  - Open new terminal with optional command
#   close_terminal [delay]              - Close current terminal window

# Get the directory where this script is located
_TERMINAL_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source dependencies
source "${_TERMINAL_LIB_DIR}/detect-terminal.sh"

# Load the appropriate adapter
_load_adapter() {
    local terminal
    terminal=$(detect_terminal)

    local adapter_path="${_TERMINAL_LIB_DIR}/adapters/${terminal}.sh"

    # Fallback to generic if adapter doesn't exist
    if [[ ! -f "$adapter_path" ]]; then
        adapter_path="${_TERMINAL_LIB_DIR}/adapters/generic.sh"
    fi

    source "$adapter_path"
}

# Open new terminal window
# Args: $1 = path, $2 = command (optional)
# Returns: 0 on success, 1 on failure, 2 if terminal opened but command failed
open_new_terminal() {
    local path="$1"
    local command="${2:-}"

    _load_adapter
    adapter_open_terminal "$path" "$command"
    return $?
}

# Close current terminal window
# Args: $1 = delay in seconds (default: 3)
close_terminal() {
    local delay="${1:-3}"

    _load_adapter
    adapter_close_terminal "$delay"
}

# Get detected terminal name
get_terminal_name() {
    _load_adapter
    adapter_name
}
