#!/bin/sh
set -e
# Source: https://github.com/sharkdp/bat

# Check if bat is already installed
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