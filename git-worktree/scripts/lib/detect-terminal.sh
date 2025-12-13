#!/bin/bash
#
# detect-terminal.sh - Auto-detect current terminal emulator
#
# Usage: source "${SCRIPT_DIR}/lib/detect-terminal.sh"
#        terminal=$(detect_terminal)

# Detect the current terminal emulator
# Returns: macos-terminal, macos-iterm, linux-gnome, linux-kitty, linux-konsole, windows-wt, generic
detect_terminal() {
    # macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Check for iTerm2
        if [[ -n "$ITERM_SESSION_ID" ]]; then
            echo "macos-iterm"
            return 0
        fi
        # Check for Kitty on macOS
        if [[ -n "$KITTY_WINDOW_ID" ]]; then
            echo "linux-kitty"  # Kitty uses same interface
            return 0
        fi
        # Default to Terminal.app
        echo "macos-terminal"
        return 0
    fi

    # Linux
    if [[ "$OSTYPE" == "linux"* ]]; then
        # Check for Kitty
        if [[ -n "$KITTY_WINDOW_ID" ]]; then
            echo "linux-kitty"
            return 0
        fi
        # Check for GNOME Terminal
        if [[ -n "$GNOME_TERMINAL_SCREEN" ]] || [[ "$COLORTERM" == "gnome-terminal" ]]; then
            echo "linux-gnome"
            return 0
        fi
        # Check for Konsole
        if [[ -n "$KONSOLE_VERSION" ]]; then
            echo "linux-konsole"
            return 0
        fi
        # Check for Alacritty
        if [[ -n "$ALACRITTY_WINDOW_ID" ]]; then
            echo "linux-alacritty"
            return 0
        fi
        # Check for xterm
        if [[ "$TERM" == "xterm"* ]]; then
            echo "linux-xterm"
            return 0
        fi
        # Generic fallback
        echo "generic"
        return 0
    fi

    # Windows (Git Bash, MSYS2, Cygwin)
    if [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]]; then
        # Check for Windows Terminal
        if [[ -n "$WT_SESSION" ]]; then
            echo "windows-wt"
            return 0
        fi
        echo "windows-generic"
        return 0
    fi

    # Unknown
    echo "generic"
}

# Get adapter script path for detected terminal
get_adapter_path() {
    local terminal="$1"
    local script_dir="$2"
    local adapter_path="${script_dir}/lib/adapters/${terminal}.sh"

    if [[ -f "$adapter_path" ]]; then
        echo "$adapter_path"
        return 0
    fi

    # Fallback to generic
    echo "${script_dir}/lib/adapters/generic.sh"
}
