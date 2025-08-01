if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    curl -L -o Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip
    echo "Installing fonts to user directory..."
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
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    brew install --cask font-hack-nerd-font
else
    # Unknown.
    echo "Unknown OS detected. Please install manually."
    exit 1
fi