source $PWD/tools/helpers.sh

config_dir="${HOME}/.config/db_setup_config"
mkdir -p $config_dir

ln -s $PWD/functions $config_dir
ln -s $PWD/bin $config_dir
ln -s $PWD/.dotfiles-shell-ext $HOME/.dotfiles-shell-ext

[[ ! -e $PWD/vars.env ]] && touch $PWD/vars.env
[[ ! -e $config_dir/cred.env ]] && touch $PWD/cred.env
[[ ! -e $config_dir/functions/scripts/extra ]] && mkdir -p $PWD/functions/scripts/extra && touch "$PWD/functions/scripts/extra/extra"

ln -s $PWD/vars.env $config_dir/vars.env
ln -s $PWD/cred.env $config_dir/cred.env

pth="$(get_startup_file_path)"
cat << EOF >> $pth

# start custom alias/funcs setup
source ${HOME}/.dotfiles-shell-ext

# adding bin to path
export PATH="${config_dir}/bin:\$PATH"

EOF

echo "bootstrap - setup completed"