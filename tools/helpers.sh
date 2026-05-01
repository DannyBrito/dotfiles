#!/bin/sh
set -eu

# Helper functions for dotfiles setup
# Note: This file must be standalone - detect.sh is set up by bootstrap later

get_shell_type() {
    # Detect the user's default shell from $SHELL env var
    # Note: When running as /bin/sh script, ZSH_VERSION/BASH_VERSION won't be set
    # So we primarily rely on $SHELL which reflects the user's login shell
    local user_shell
    user_shell="$(basename "${SHELL:-sh}")"

    case "$user_shell" in
        zsh|bash|fish) echo "$user_shell" ;;
        *)
            # Fallback: check running shell version vars (for interactive use)
            if [ -n "${ZSH_VERSION:-}" ]; then
                echo "zsh"
            elif [ -n "${BASH_VERSION:-}" ]; then
                echo "bash"
            elif [ -n "${FISH_VERSION:-}" ]; then
                echo "fish"
            else
                echo "sh"
            fi
            ;;
    esac
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

# Get interactive shell config file (.zshrc, .bashrc)
# Use this for evals, prompts, aliases - things that need shell-specific syntax
# Returns empty string for unknown shells (caller should handle this)
get_interactive_shell_config() {
    local shell_type
    shell_type="$(get_shell_type)"

    case "$shell_type" in
        zsh)  echo "$HOME/.zshrc" ;;
        bash) echo "$HOME/.bashrc" ;;
        *)    echo "" ;;  # Unknown shell - caller must handle
    esac
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