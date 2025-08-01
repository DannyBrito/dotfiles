#!/bin/bash
set -e
# Source: https://github.com/sharkdp/bat

# Check if bat is already installed
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    sudo apt-get install -y bat
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    brew install bat
else
    # Unknown.
    echo "Unknown OS detected. Please install manually."
    exit 1
fi