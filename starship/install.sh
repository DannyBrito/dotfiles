set -e

# Install font:
$PWD/starship/install-font.sh
# Install starship
curl -sS https://starship.rs/install.sh | sh

mkdir -p $HOME/.config
mv $HOME/.config/starship.toml $HOME/.config/starship.old.toml
ln -s $PWD/starship/starship.toml $HOME/.config/starship.toml

local os_shell="bash"
local os_shell_file=".bashrc"
if [[ "$OSTYPE" == "darwin"* ]]; then
    os_shell="zsh"
    os_shell_file=".zshrc"
fi

cat << EOF >> $HOME/$os_shell_file

# Startship Setup
eval "\$(starship init $os_shell)"

EOF

echo "starship - setup completed!"