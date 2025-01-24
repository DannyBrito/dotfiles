set -e

echo "installing starship:"
$PWD/tools/starship/install.sh

echo "installing fzf:"
$PWD/tools/fzf/install.sh

echo "installing bcat:"
$PWD/tools/bcat/install.sh