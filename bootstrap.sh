
config_dir="${HOME}/.config/db_setup_config"
mkdir -p $config_dir

ln -s $PWD/alias_funcs $config_dir/alias_funcs
ln -s $PWD/.bash_profile_ext $HOME/.bash_profile_ext
ln -s $PWD/starship/starship.toml $HOME/.config/starship.toml

[[ ! -e $PWD/vars.env ]] && touch $PWD/vars.env
[[ ! -e $config_dir/cred.env ]] && touch $config_dir/cred.env
[[ ! -e $config_dir/alias_funcs/extra ]] && touch "$config_dir/alias_funcs/extra"

ln -s $PWD/vars.env $config_dir/vars.env

pth="~/.${SHELL##*/}rc"
cat << EOF >> $pth

# start custom alias/funcs setup
source ${HOME}/.bash_profile_ext

EOF

echo "bootstrap - setup completed"