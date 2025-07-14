#!/bin/bash
set -euo pipefail

# Helper functions for dotfiles setup

get_shell_type() {
    basename "$SHELL"
}

get_startup_file_path() {
    local shell_type
    shell_type="$(get_shell_type)"
    local rc_file="${shell_type}rc"
    echo "$HOME/.$rc_file"
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
        source "$file"
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

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    elif [[ "$OSTYPE" == "msys" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}