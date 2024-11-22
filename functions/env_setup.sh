#!/bin/sh

export config_dir="${HOME}/.config/db_setup_config"
export functions_dir="${config_dir}/functions"
export alias_scripts_dir="${functions_dir}/scripts"

# These variables can be overwriten on the vars.env file
export dev_dir="/mount/d/dev"
export _dotfiles_dir="${dev_dir}/danny-gh/dotfiles"

if [[ -e "${config_dir}/vars.env" && -s "${config_dir}/vars.env" ]]; then
    export $(xargs <${config_dir}/vars.env)
fi