#!/bin/sh
set -e

. "$PWD/tools/helpers.sh"

# Install font:
"$PWD/tools/starship/install-font.sh"

# Install starship if not present
if command -v starship >/dev/null 2>&1; then
    echo "starship is already installed, skipping binary install"
else
    mkdir -p "$HOME/.local/bin"
    curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$HOME/.local/bin"
fi

mkdir -p "$HOME/.config"

# Setup starship config (idempotent)
if [ -L "$HOME/.config/starship.toml" ]; then
    echo "starship.toml already linked"
elif [ -e "$HOME/.config/starship.toml" ]; then
    mv "$HOME/.config/starship.toml" "$HOME/.config/starship.old.toml"
    ln -s "$PWD/tools/starship/starship.toml" "$HOME/.config/starship.toml"
else
    ln -s "$PWD/tools/starship/starship.toml" "$HOME/.config/starship.toml"
fi

if [ ! -L "$HOME/.config/starship.no-font.toml" ]; then
    ln -s "$PWD/tools/starship/starship.no-font.toml" "$HOME/.config/starship.no-font.toml" 2>/dev/null || true
fi

# Add starship init to interactive shell config (must be .zshrc/.bashrc, not .profile)
# The eval generates shell-specific code that won't work in POSIX .profile
pth="$(get_interactive_shell_config)"
shell_type="$(get_shell_type)"
marker="starship init"

# Skip if unknown shell (can't generate proper init)
if [ -z "$pth" ]; then
    echo "Unknown shell type '$shell_type' - skipping starship init setup"
    echo "To enable starship, manually add to your shell config:"
    echo "  eval \"\$(starship init YOUR_SHELL)\""
else
    # Ensure the file exists
    [ ! -f "$pth" ] && touch "$pth"

    if grep -q "$marker" "$pth" 2>/dev/null; then
        echo "starship already configured in $pth"
    else
        cat << EOF >> "$pth"

# Starship Setup
eval "\$(starship init $shell_type)"

EOF
        echo "Added starship init to $pth"
    fi
fi

echo "starship - setup completed!"
