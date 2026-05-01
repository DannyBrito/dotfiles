#!/bin/sh
set -e

# Install starship binary and optionally fonts
# Adds starship init to shell config

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

. "$DOTFILES_DIR/tools/helpers.sh"

# Install font (optional, for "full" style)
if [ "${1:-}" = "--with-font" ] || [ "${1:-}" = "-f" ]; then
    "$SCRIPT_DIR/install-font.sh"
fi

# Install starship if not present
if command -v starship >/dev/null 2>&1; then
    echo "starship is already installed"
else
    echo "Installing starship..."
    mkdir -p "$HOME/.local/bin"
    curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$HOME/.local/bin"
fi

# Add starship init to shell config
shell_type="$(get_shell_type)"
shell_config="$(get_interactive_shell_config)"
marker="starship init"

if [ -z "$shell_config" ]; then
    echo "Unknown shell type '$shell_type' - skipping starship init setup"
    echo "Manually add to your shell config: eval \"\$(starship init YOUR_SHELL)\""
else
    [ ! -f "$shell_config" ] && touch "$shell_config"

    if grep -q "$marker" "$shell_config" 2>/dev/null; then
        echo "starship init already in $shell_config"
    else
        cat << EOF >> "$shell_config"

# Starship prompt
eval "\$(starship init $shell_type)"
EOF
        echo "Added starship init to $shell_config"
    fi
fi

echo ""
echo "starship installed!"
echo ""
echo "Prompt styles are managed via: prompt-style"
echo "  prompt-style          # fzf picker"
echo "  prompt-style full     # with nerd fonts"
echo "  prompt-style minimal  # no special fonts"
echo "  prompt-style off      # fallback prompt"
echo ""
echo "To install fonts for 'full' style: $SCRIPT_DIR/install-font.sh"
