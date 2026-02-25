#!/bin/sh
set -eu

# Helper functions for dotfiles setup
# Note: This file must be standalone - detect.sh is set up by bootstrap later

get_shell_type() {
    # Detect the actual running shell, not just $SHELL
    if [ -n "${ZSH_VERSION:-}" ]; then
        echo "zsh"
    elif [ -n "${BASH_VERSION:-}" ]; then
        echo "bash"
    elif [ -n "${FISH_VERSION:-}" ]; then
        echo "fish"
    else
        # Fallback to $SHELL
        basename "${SHELL:-sh}"
    fi
}

get_startup_file_path() {
    local shell_type
    shell_type="$(get_shell_type)"

    local shell_profile
    case "$shell_type" in
        bash) shell_profile="$HOME/.bash_profile" ;;
        zsh)  shell_profile="$HOME/.zprofile" ;;
        *)    shell_profile="" ;;
    esac

    if [ -n "$shell_profile" ] && [ -f "$shell_profile" ]; then
        echo "$shell_profile"
    else
        echo "$HOME/.profile"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Safe way to source a file
safe_source() {
    local file="$1"
    if [ -f "$file" ] && [ -r "$file" ]; then
        # shellcheck source=/dev/null
        . "$file"
        return 0
    else
        echo "Warning: Cannot source file: $file" >&2
        return 1
    fi
}

# Create backup of existing file
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup"
        echo "Created backup: $backup"
    fi
}

# Log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}