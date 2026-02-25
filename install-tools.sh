#!/bin/sh
set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing starship..."
"$SCRIPT_DIR/tools/starship/install.sh"

echo "Installing fzf..."
"$SCRIPT_DIR/tools/fzf/install.sh"

# Skip bcat installation if SKIP_BCAT is set (useful for containers)
if [ -n "${SKIP_BCAT:-}" ]; then
    echo "Skipping bcat installation (SKIP_BCAT is set)"
    exit 0
fi

echo "Installing bcat..."
"$SCRIPT_DIR/tools/bcat/install.sh"

echo ""
echo "All tools installed successfully!"