set -e

echo "trying to install fzf via ~/.fzf/install:"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
