#!/bin/sh
set -e

# Install Hack Nerd Font

case "$(uname -s)" in
    Linux*)
        # Check if Hack Nerd Font is already installed
        if fc-list 2>/dev/null | grep -qi "Hack.*Nerd"; then
            echo "Hack Nerd Font is already installed"
            exit 0
        fi

        echo "Installing Hack Nerd Font for Linux..."
        curl -L -o Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip
        mkdir -p ~/.local/share/fonts/
        if command -v unzip >/dev/null 2>&1; then
            unzip -j Hack.zip '*.ttf' -d ~/.local/share/fonts/
            # Update font cache if fc-cache is available
            if command -v fc-cache >/dev/null 2>&1; then
                fc-cache -f ~/.local/share/fonts/
            fi
        else
            echo "Warning: unzip not available, skipping font installation"
        fi
        rm -f Hack.zip
        echo "Hack Nerd Font installed"
        ;;
    Darwin*)
        # Check if already installed via brew
        if brew list --cask font-hack-nerd-font >/dev/null 2>&1; then
            echo "Hack Nerd Font is already installed"
            exit 0
        fi

        echo "Installing Hack Nerd Font for macOS..."
        brew install --cask font-hack-nerd-font
        echo "Hack Nerd Font installed"
        echo "Note: Set terminal font to 'Hack Nerd Font Mono' for icons"
        ;;
    *)
        echo "Unknown OS detected. Please install manually."
        exit 1
        ;;
esac