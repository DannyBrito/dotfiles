# 🔧 dotfiles

This repo contains all the aliases and functions I use on my machines.

## Quick Start

```sh
git clone https://github.com/DannyBrito/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

This will:
1. Create symlinks for dotfiles configuration
2. Set up shell profile sourcing
3. Create `vars.env` and `cred.env` for custom configuration

Then start a new terminal or run `. ~/.profile` to activate.

## Installing Tools

```sh
./install-tools.sh
```

Installs: Starship prompt, fzf, bat

## Configuration

| File | Purpose |
|------|---------|
| `vars.env` | Custom environment variables (git-ignored) |
| `cred.env` | Credentials, loaded on-demand via `git-cred` |
| `functions/scripts/extra/extra` | extra (git-ignored) |

## Directory Structure

```
├── bootstrap.sh           # Main setup script
├── install-tools.sh       # Tool installer
├── bin/                   # Executable scripts (added to PATH)
├── functions/
│   ├── env_setup.sh       # Environment initialization
│   └── scripts/           # Aliases and functions
│       ├── common.sh
│       ├── git.sh
│       ├── docker.sh
│       ├── detect.sh
│       └── extra/
├── tools/                 # Tool installers
│   ├── starship/          # Starship prompt
│   ├── fzf/               # Fuzzy finder
│   └── bcat/              # bat (better cat)
└── macos/                 # macOS-specific
```