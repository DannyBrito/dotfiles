#!/bin/sh
set -eu

# Bootstrap script for dotfiles setup
# Idempotent - safe to run multiple times

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DOTFILES_DIR/tools/helpers.sh"

# shellcheck source=./tools/validate.sh
. "$DOTFILES_DIR/tools/validate.sh"

# Detect environment type
detect_env() {
    if [ -n "${CODESPACES:-}" ]; then
        echo "codespaces"
    elif [ -n "${GITPOD_WORKSPACE_ID:-}" ]; then
        echo "gitpod"
    elif [ -f /.dockerenv ]; then
        echo "docker"
    elif [ -n "${WSL_DISTRO_NAME:-}" ]; then
        echo "wsl"
    elif [ -n "${SSH_CONNECTION:-}" ]; then
        echo "ssh"
    else
        echo "local"
    fi
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *)       echo "unknown" ;;
    esac
}

# Create symlink only if target differs (idempotent)
safe_symlink() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        local current_target
        current_target="$(readlink "$dest" 2>/dev/null || true)"
        if [ "$current_target" = "$src" ]; then
            log "  ✓ $dest (unchanged)"
            return 0
        fi
        log "  ↻ $dest (updating)"
        rm "$dest"
    elif [ -e "$dest" ]; then
        log "  ⚠ $dest exists (backing up)"
        backup_file "$dest"
        rm -rf "$dest"
    else
        log "  + $dest (new)"
    fi
    ln -s "$src" "$dest"
}

# Add content to file if marker not present (idempotent)
add_to_file_if_missing() {
    local file="$1"
    local marker="$2"
    local content="$3"

    if [ -f "$file" ] && grep -q "$marker" "$file" 2>/dev/null; then
        log "  ✓ $file already configured"
        return 0
    fi

    if [ -f "$file" ]; then
        log "  ↻ $file (appending)"
    else
        log "  + $file (creating)"
    fi

    echo "$content" >> "$file"
}

# Prepend content to file if marker not present (idempotent)
prepend_to_file_if_missing() {
    local file="$1"
    local marker="$2"
    local content="$3"

    if [ -f "$file" ] && grep -q "$marker" "$file" 2>/dev/null; then
        log "  ✓ $file already configured"
        return 0
    fi

    log "  ↻ $file (prepending)"
    [ -f "$file" ] && backup_file "$file"

    local temp_file
    temp_file=$(mktemp)
    echo "$content" > "$temp_file"
    [ -f "$file" ] && cat "$file" >> "$temp_file"
    mv "$temp_file" "$file"
}

setup_symlinks() {
    local config_dir="$1"

    log "🔗 Setting up symlinks..."
    safe_symlink "$DOTFILES_DIR/functions" "$config_dir/functions"
    safe_symlink "$DOTFILES_DIR/bin" "$config_dir/bin"
    safe_symlink "$DOTFILES_DIR/tools" "$config_dir/tools"
    safe_symlink "$DOTFILES_DIR/.dotfiles-shell-ext" "$HOME/.dotfiles-shell-ext"
    safe_symlink "$DOTFILES_DIR/vars.env" "$config_dir/vars.env"
    safe_symlink "$DOTFILES_DIR/cred.env" "$config_dir/cred.env"
}

setup_environment_files() {
    log "📝 Setting up environment files..."
    [ ! -e "$DOTFILES_DIR/vars.env" ] && touch "$DOTFILES_DIR/vars.env" && log "  + vars.env"
    [ ! -e "$DOTFILES_DIR/cred.env" ] && touch "$DOTFILES_DIR/cred.env" && log "  + cred.env"

    if [ ! -e "$DOTFILES_DIR/functions/scripts/extra/extra" ]; then
        mkdir -p "$DOTFILES_DIR/functions/scripts/extra"
        touch "$DOTFILES_DIR/functions/scripts/extra/extra"
        log "  + functions/scripts/extra/extra"
    fi
}

setup_shell_profile() {
    local config_dir="$1"
    local env_type="$2"
    local shell_type
    shell_type="$(get_shell_type)"

    log "🐚 Configuring shell ($shell_type) for $env_type environment..."

    # Ensure .profile exists
    [ ! -f "$HOME/.profile" ] && touch "$HOME/.profile"

    # Add dotfiles config to .profile (at top to avoid conflicts)
    local profile_content
    profile_content="# Dotfiles configuration - managed by bootstrap
# Prevent multiple sourcing
if [ -n \"\${DOTFILES_PROFILE_LOADED:-}\" ]; then
    return 2>/dev/null || true
fi
DOTFILES_PROFILE_LOADED=1

# Source dotfiles shell extensions
[ -f \"\$HOME/.dotfiles-shell-ext\" ] && . \"\$HOME/.dotfiles-shell-ext\"

# Add bin directories to path
export PATH=\"\$HOME/.local/bin:\$HOME/.fzf/bin:${config_dir}/bin:\$PATH\"
"
    prepend_to_file_if_missing "$HOME/.profile" "DOTFILES_PROFILE_LOADED" "$profile_content"

    # Handle shell-specific startup files
    local startup_file
    startup_file="$(get_startup_file_path)"

    if [ "$startup_file" != "$HOME/.profile" ]; then
        local source_profile="
# Source .profile for dotfiles configuration
[ -f \"\$HOME/.profile\" ] && . \"\$HOME/.profile\"
"
        add_to_file_if_missing "$startup_file" ".profile" "$source_profile"
    fi

    # Environment-specific setup
    case "$env_type" in
        codespaces|gitpod|docker)
            # These environments often use .bashrc for interactive shells
            if [ -f "$HOME/.bashrc" ] || [ "$env_type" = "codespaces" ]; then
                local bashrc_content="
# Source .profile for dotfiles configuration ($env_type)
[ -f \"\$HOME/.profile\" ] && . \"\$HOME/.profile\"
"
                add_to_file_if_missing "$HOME/.bashrc" ".profile" "$bashrc_content"
            fi
            ;;
        wsl)
            # WSL may need both .bashrc and .zshrc
            if [ -f "$HOME/.bashrc" ]; then
                add_to_file_if_missing "$HOME/.bashrc" ".profile" "[ -f \"\$HOME/.profile\" ] && . \"\$HOME/.profile\""
            fi
            ;;
    esac
}

print_summary() {
    local env_type="$1"
    local os_type="$2"

    log ""
    log "🎉 Bootstrap completed!"
    log "   Environment: $env_type"
    log "   OS: $os_type"
    log "   Shell: $(get_shell_type)"
    log ""
    log "Next steps:"
    log "   • Start a new terminal, or run: . ~/.profile"
    log "   • Optional: Run ./install-tools.sh to install fzf, starship, etc."
}

main() {
    local env_type
    local os_type
    env_type="$(detect_env)"
    os_type="$(detect_os)"

    log "🚀 Starting dotfiles bootstrap..."
    log "   Environment: $env_type | OS: $os_type | Shell: $(get_shell_type)"
    log ""

    # Run validations
    validate_dependencies
    validate_shell
    validate_permissions

    local config_dir="${HOME}/.config/db_setup_config"
    log "📁 Config directory: $config_dir"
    mkdir -p "$config_dir"

    setup_environment_files
    setup_symlinks "$config_dir"
    setup_shell_profile "$config_dir" "$env_type"

    print_summary "$env_type" "$os_type"
}

if [ "${0##*/}" = "bootstrap.sh" ]; then
    main "$@"
fi