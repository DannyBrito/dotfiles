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
    
    # Ensure the startup file exists with proper defaults
    if [[ ! -e "$startup_file" ]]; then
        log "📄 Creating default startup file..."
        if [[ "$startup_file" == *".bashrc" ]]; then
            log "Creating default .bashrc from /etc/skel/.bashrc"
            cp /etc/skel/.bashrc "$startup_file"
        elif [[ "$startup_file" == *".zshrc" ]]; then
            log "Creating default .zshrc"
            cat << 'ZSHRC_EOF' > "$startup_file"
# Default .zshrc configuration
# Set up the prompt
autoload -Uz compinit
compinit

# History configuration
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_find_no_dups

# Enable completion
autoload -U compinit && compinit

# Basic aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
ZSHRC_EOF
        else
            log "Creating default profile file"
            touch "$startup_file"
        fi
    fi
    
    # Check if our configuration is already added to avoid duplicates
    if ! grep -q "start custom alias/funcs setup" "$startup_file"; then
        log "➕ Adding dotfiles configuration to $startup_file"
        # Create backup before modification
        backup_file "$startup_file"
        
        cat << EOF >> "$startup_file"

# start custom alias/funcs setup
source ${HOME}/.dotfiles-shell-ext

# adding bin to path
export PATH="${config_dir}/bin:\$PATH"

EOF
    else
        log "✅ Dotfiles configuration already exists in $startup_file"
    fi
    
    log "🎉 Bootstrap setup completed successfully!"
    log "📌 Please restart your shell or run: source $startup_file"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi