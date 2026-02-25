#!/bin/sh
# Environment setup - uses POSIX sh for compatibility

export config_dir="${HOME}/.config/db_setup_config"
export functions_dir="${config_dir}/functions"
export alias_scripts_dir="${functions_dir}/scripts"

# These variables can be overwritten on the vars.env file
export dev_dir="/mount/d/dev"
export _dotfiles_dir="${dev_dir}/danny-gh/dotfiles"

# Load vars.env if it exists and has content (POSIX compliant)
if [ -e "${config_dir}/vars.env" ] && [ -s "${config_dir}/vars.env" ]; then
    # Use set -a to auto-export, avoiding issues with special characters
    set -a
    # shellcheck source=/dev/null
    . "${config_dir}/vars.env"
    set +a
fi