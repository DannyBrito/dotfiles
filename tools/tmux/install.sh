#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Install tmux if not present
if command -v tmux >/dev/null 2>&1; then
    echo "tmux is already installed"
else
    echo "Installing tmux..."
    case "$(uname -s)" in
        Darwin*)
            if command -v brew >/dev/null 2>&1; then
                brew install tmux
            else
                echo "Error: brew not found. Please install Homebrew first."
                exit 1
            fi
            ;;
        Linux*)
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get update && sudo apt-get install -y tmux
            elif command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y tmux
            elif command -v pacman >/dev/null 2>&1; then
                sudo pacman -S --noconfirm tmux
            else
                echo "Error: No supported package manager found"
                exit 1
            fi
            ;;
        *)
            echo "Error: Unsupported OS"
            exit 1
            ;;
    esac
fi

# Setup tmux config symlink (idempotent)
if [ -L "$HOME/.tmux.conf" ]; then
    echo "tmux config already linked"
elif [ -e "$HOME/.tmux.conf" ]; then
    echo "tmux config exists, backing up..."
    mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup"
    ln -s "$SCRIPT_DIR/.tmux.conf" "$HOME/.tmux.conf"
else
    ln -s "$SCRIPT_DIR/.tmux.conf" "$HOME/.tmux.conf"
fi

echo "tmux setup complete"