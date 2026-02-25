#!/bin/sh
set -e
# Source: https://github.com/sharkdp/bat

# Check if bat/batcat is already installed
if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    echo "bat is already installed, skipping"
    exit 0
fi

case "$(uname -s)" in
    Linux*)
        sudo apt-get install -y bat
        ;;
    Darwin*)
        brew install bat
        ;;
    *)
        echo "Unknown OS detected. Please install manually."
        exit 1
        ;;
esac
echo "bat installation complete"