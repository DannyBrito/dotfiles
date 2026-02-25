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

# Only add to profile if not already present
pth="$(get_startup_file_path)"
marker="starship init"

if grep -q "$marker" "$pth" 2>/dev/null; then
    echo "starship already configured in $pth"
else
    cat << EOF >> "$pth"

# Starship Setup
eval "\$(starship init $(get_shell_type))"

EOF
    echo "Added starship init to $pth"
fi

echo "starship - setup completed!"
