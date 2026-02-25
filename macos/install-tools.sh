#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not installed. Please install it first."
    exit 1
fi

echo "Installing tools from tools.txt..."
grep -v '^#' "$SCRIPT_DIR/tools.txt" | grep -v '^$' | while read -r line; do
    brew install $line
done

echo ""
echo "macOS tools installation complete"
