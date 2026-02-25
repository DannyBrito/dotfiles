#!/bin/sh
set -e

# Only create symlink if not already present
if [ -L "$HOME/.tmux.conf" ]; then
    echo "tmux config already linked"
elif [ -e "$HOME/.tmux.conf" ]; then
    echo "tmux config exists, backing up..."
    mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup"
    ln -s "$PWD/tools/tmux/.tmux.conf" "$HOME/.tmux.conf"
else
    ln -s "$PWD/tools/tmux/.tmux.conf" "$HOME/.tmux.conf"
fi
echo "tmux setup complete"