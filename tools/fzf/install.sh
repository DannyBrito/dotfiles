#!/bin/sh
set -e

# Check if fzf is already installed
if command -v fzf >/dev/null 2>&1; then
    echo "fzf is already installed, skipping installation"
    exit 0
fi

echo "trying to install fzf via ~/.fzf/install:"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
# Run fzf install with minimal setup - don't modify shell configs
~/.fzf/install --bin --no-bash --no-zsh --no-fish
