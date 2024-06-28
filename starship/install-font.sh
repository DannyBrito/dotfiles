
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip
    mkdir -p ~/.local/share/fonts/
    sudo unzip Hack.zip '*.ttf' -d ~/.local/share/fonts/
    rm Hack.zip
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    brew install --cask font-hack-nerd-font
else
    # Unknown.
    echo "Unknown OS detected. Please install manually."
    exit 1
fi