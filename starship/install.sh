set -e

source $PWD/installer/helpers.sh

# Install font:
$PWD/starship/install-font.sh
# Install starship
curl -sS https://starship.rs/install.sh | sh

mkdir -p $HOME/.config
mv $HOME/.config/starship.toml $HOME/.config/starship.old.toml || true
ln -s $PWD/starship/starship.toml $HOME/.config/starship.toml
ln -s $PWD/starship/starship.no-font.toml $HOME/.config/starship.no-font.toml

pth="$(get_startup_file_path)"
cat << EOF >> $pth

# Startship Setup
eval "\$(starship init $(get_shell_type))"

EOF

echo "starship - setup completed!"
