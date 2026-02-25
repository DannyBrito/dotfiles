#!/bin/sh
set -e

echo "installing starship:"
$PWD/tools/starship/install.sh

echo "installing fzf:"
$PWD/tools/fzf/install.sh

# Skip bcat installation if SKIP_BCAT is set (useful for containers)
if [ -n "${SKIP_BCAT:-}" ]; then
    echo "Skipping bcat installation (SKIP_BCAT is set)"
    exit 0
fi
echo "installing bcat:"
$PWD/tools/bcat/install.sh