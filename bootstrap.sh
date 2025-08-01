#!/bin/bash
set -euo pipefail

# Bootstrap script for dotfiles setup
# shellcheck source=./tools/helpers.sh
source "$PWD/tools/helpers.sh"

# shellcheck source=./tools/validate.sh
source "$PWD/tools/validate.sh"

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
[ -f "$HOME/.profile" ] && source "$HOME/.profile"
EOF
        else
            log "✅ $startup_file already sources .profile"
        fi
    fi

    # Add our dotfiles configuration to .profile with guard
    if ! grep -q "DOTFILES_PROFILE_LOADED" "$HOME/.profile"; then
        log "➕ Adding dotfiles configuration to .profile"
        backup_file "$HOME/.profile"

        cat << EOF >> "$HOME/.profile"

# Prevent multiple sourcing
[ -n "\${DOTFILES_PROFILE_LOADED:-}" ] && return
DOTFILES_PROFILE_LOADED=1

# start custom alias/funcs setup
source ${HOME}/.dotfiles-shell-ext

# adding bin to path
export PATH="${config_dir}/bin:\$PATH"
EOF
    else
        log "✅ Dotfiles configuration already exists in .profile"
    fi

    log "🎉 Bootstrap setup completed successfully!"
    log "Loading dotfiles configuration..."
    source "$HOME/.profile"
    log "✅ Dotfiles configuration loaded!"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi