#!/bin/sh
set -e

# Install macOS-specific tools from tools.txt
if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not installed. Please install it first."
    exit 1
fi

echo "Installing tools from macos/tools.txt..."
brew install $(cat "$PWD/macos/tools.txt")
echo "macOS tools installation complete"
