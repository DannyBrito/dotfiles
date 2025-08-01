#!/bin/bash
set -euo pipefail

# Bootstrap script for dotfiles setup
. "$PWD/tools/helpers.sh"

# shellcheck source=./tools/validate.sh
. "$PWD/tools/validate.sh"

main() {
    log "🚀 Starting dotfiles bootstrap process..."

    # Run validations first
    validate_dependencies
    validate_shell
    validate_permissions

    local config_dir="${HOME}/.config/db_setup_config"
    log "📁 Creating configuration directory: $config_dir"
    mkdir -p "$config_dir"

    # Create symlinks
    log "🔗 Creating symlinks..."
    ln -sf "$PWD/functions" "$config_dir"
    ln -sf "$PWD/bin" "$config_dir"
    ln -sf "$PWD/.dotfiles-shell-ext" "$HOME/.dotfiles-shell-ext"

    # Create environment files
    log "📝 Setting up environment files..."
    [[ ! -e "$PWD/vars.env" ]] && touch "$PWD/vars.env"
    [[ ! -e "$config_dir/cred.env" ]] && touch "$PWD/cred.env"
    [[ ! -e "$config_dir/functions/scripts/extra" ]] && {
        mkdir -p "$PWD/functions/scripts/extra"
        touch "$PWD/functions/scripts/extra/extra"
    }

    ln -sf "$PWD/vars.env" "$config_dir/vars.env"
    ln -sf "$PWD/cred.env" "$config_dir/cred.env"

    # Configure shell startup file
    local startup_file
    startup_file="$(get_startup_file_path)"
    log "🐚 Configuring shell startup file: $startup_file"

    # Handle shell-specific profile files - make them source .profile
    if [[ "$startup_file" != *".profile" ]]; then
        # Add .profile sourcing if not already present
        if [[ ! -e "$startup_file" ]] || ! grep -q "\.profile" "$startup_file"; then
            if [[ -e "$startup_file" ]]; then
                log "➕ Adding .profile sourcing to existing $startup_file"
                backup_file "$startup_file"
            else
                log "📄 Creating $startup_file to source .profile"
            fi
            cat << EOF >> "$startup_file"

# Source .profile for environment setup
[ -f "$HOME/.profile" ] && . "$HOME/.profile"
EOF
        else
            log "✅ $startup_file already sources .profile"
        fi
    fi

    # Add our dotfiles configuration to .profile with guard (at the top to avoid conflicts)
    if ! grep -q "DOTFILES_PROFILE_LOADED" "$HOME/.profile"; then
        log "➕ Adding dotfiles configuration to .profile"
        backup_file "$HOME/.profile"

        # Create a temporary file with our config at the top
        local temp_profile=$(mktemp)
        cat << EOF > "$temp_profile"
# Prevent multiple sourcing
if [ -n "\${DOTFILES_PROFILE_LOADED:-}" ]; then
    return 2>/dev/null || true
fi
DOTFILES_PROFILE_LOADED=1

# start custom alias/funcs setup
. ${HOME}/.dotfiles-shell-ext

# adding bin directories to path
export PATH="$HOME/.local/bin:$HOME/.fzf/bin:${config_dir}/bin:\$PATH"

EOF
        # Append existing .profile content if it exists
        [[ -f "$HOME/.profile" ]] && cat "$HOME/.profile" >> "$temp_profile"
        # Replace .profile with our new content
        mv "$temp_profile" "$HOME/.profile"
    else
        log "✅ Dotfiles configuration already exists in .profile"
    fi

#     # Also add to .bashrc for interactive shells (like Codespaces)
#     # Check if we're in Codespaces environment
#     if [[ -n "${CODESPACES:-}" ]]; then
#         log "🔍 Detected Codespaces environment"
#         if ! grep -q "\.profile" "$HOME/.bashrc" 2>/dev/null; then
#             log "➕ Adding .profile sourcing to .bashrc for Codespaces"
#             backup_file "$HOME/.bashrc"
#             cat << EOF >> "$HOME/.bashrc"

# # Source .profile for dotfiles configuration (Codespaces)
# [ -f "$HOME/.profile" ] && . "$HOME/.profile"
# EOF
#         else
#             log "✅ .bashrc already sources .profile"
#         fi
#     fi
    log "🎉 Bootstrap setup completed successfully!"
    log "Please start a new terminal session or run: . ~/.profile"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi