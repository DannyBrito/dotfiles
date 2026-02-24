#!/bin/bash
# Ensure az CLI is in PATH (Shortcuts uses minimal PATH)
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
# Source credentials (for AZ_DANNY, AZ_AZCU variables)
source "$HOME/dev/danny/dotfiles/vars.env"
# Source the extra functions
source "$HOME/dev/danny/dotfiles/functions/scripts/extra/extra"
# Run the function
wake-dev-vm
