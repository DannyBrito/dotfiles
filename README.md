# .dotfiles

This repo contains all the aliases and functions I use on my machines.

## Getting Started

To set up the environment, just run:
`./bootstrap.sh`

This will create `vars.env` and `cred.env` files at the root level of the repo and symlink them to the config directory. Use `vars.env` to set extra variables or overwrite existing ones. The `cred.env` file is for credentials and will only be sourced when you call the `git-cred` function.

## Installing Tools

To install some tools (Starship, fzf, bat, tmux, etc.), run:
`./install-tools.sh`

## Directory Structure

Here's a quick overview of the repo structure:

- [bin](bin/): Contains useful scripts.
- [functions/scripts](functions/scripts/): All the alias and function scripts live here.
- [macos](macos/): macOS-specific configurations.
- [tools](tools/): Installation scripts for various tools.
- [bootstrap.sh](bootstrap.sh): Main setup script.
- [install-tools.sh](install-tools.sh): Script to install essential tools.

## Usage

After running the [bootstrap.sh](./bootstrap.sh), your shell will be set up with all the custom aliases and functions. To get all the functionality of the aliases and functions, some tools need to be installed via [install-tools.sh](./install-tools.sh).