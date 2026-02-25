#!/bin/sh
set -e

. $PWD/tools/helpers.sh

# Install font:
$PWD/tools/starship/install-font.sh

# Install starship
mkdir -p "$HOME/.local/bin"
curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$HOME/.local/bin"

mkdir -p $HOME/.config

mv $HOME/.config/starship.toml $HOME/.config/starship.old.toml || true
ln -s $PWD/tools/starship/starship.toml $HOME/.config/starship.toml
ln -s $PWD/tools/starship/starship.no-font.toml $HOME/.config/starship.no-font.toml

pth="$(get_startup_file_path)"
cat << EOF >> $pth

# Startship Setup
eval "\$(starship init $(get_shell_type))"

EOF

echo "starship - setup completed!"
