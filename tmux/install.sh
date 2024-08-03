set -e

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    apt install -y tmux
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install tmux
else
    # Unknown.
    echo "Unknown OS detected. Please install manually."
    exit 1
fi

ln -s $PWD/tmux/.tmux.conf $HOME/.tmux.conf