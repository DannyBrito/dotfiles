#!/bin/sh
# Prompt style manager - starship configs + fallback prompt
# Supports: fzf picker, persistence, auto-detection
#
# Uses: $starship_configs_dir, $prompt_style_file (from env_setup.sh)

# ============================================================================
# AUTO-DETECTION
# ============================================================================
_detect_prompt_style() {
    # TTY/dumb terminal → fallback (off)
    case "${TERM:-}" in
        linux|dumb|vt100) echo "off"; return ;;
    esac

    # Apple Terminal → minimal
    [ "${TERM_PROGRAM:-}" = "Apple_Terminal" ] && echo "minimal" && return

    # SSH without COLORTERM → minimal
    if [ -n "${SSH_CONNECTION:-}" ] && [ -z "${COLORTERM:-}" ]; then
        echo "minimal"
        return
    fi

    # Default → full
    echo "full"
}

# ============================================================================
# FALLBACK PROMPT (when starship not available or style=off)
# ============================================================================

# Git branch helper for bash fallback prompt
__prompt_git_branch() {
    git branch 2>/dev/null | sed -n 's/* \(.*\)/ (\1)/p'
}

_setup_fallback_prompt() {
    if [ -n "$ZSH_VERSION" ]; then
        # Zsh: colorful with git branch (eval to avoid sh parsing issues)
        eval 'autoload -Uz vcs_info'
        eval 'precmd() { vcs_info }'
        eval "zstyle ':vcs_info:git:*' formats ' %F{magenta}(%b)%f'"
        eval 'setopt PROMPT_SUBST'
        eval 'PROMPT='\''%F{green}%n%f %F{blue}%1~%f${vcs_info_msg_0_} %F{yellow}➜%f '\'''
    elif [ -n "$BASH_VERSION" ]; then
        # Bash: colorful with git branch
        PS1='\[\033[32m\]\u\[\033[0m\] \[\033[34m\]\W\[\033[0m\]\[\033[35m\]$(__prompt_git_branch)\[\033[0m\] \[\033[33m\]➜\[\033[0m\] '
    fi
}

# ============================================================================
# STARSHIP CONFIG SETTER
# ============================================================================
_set_starship_config() {
    local config="$1"
    [ -f "$config" ] && export STARSHIP_CONFIG="$config"
}

# ============================================================================
# MAIN SETUP FUNCTION
# ============================================================================
setup_prompt() {
    local style

    # Priority: persisted > auto-detect
    if [ -f "$prompt_style_file" ]; then
        style="$(cat "$prompt_style_file")"
    else
        style="$(_detect_prompt_style)"
    fi

    # Handle "off" or missing starship
    if [ "$style" = "off" ] || ! command -v starship >/dev/null 2>&1; then
        _setup_fallback_prompt
        return
    fi

    # Find config file - if it doesn't exist, do nothing
    local config_file="${starship_configs_dir}/${style}.toml"
    [ ! -f "$config_file" ] && return

    _set_starship_config "$config_file"
}

# ============================================================================
# USER COMMAND: prompt-style
# ============================================================================
prompt-style() {
    local arg="${1:-}"
    local config_dir="$starship_configs_dir"

    case "$arg" in
        # No argument: fzf picker or list
        "")
            if command -v fzf >/dev/null 2>&1; then
                _prompt_style_fzf
            else
                _prompt_style_list
            fi
            ;;

        # Show current style
        current)
            if [ -f "$prompt_style_file" ]; then
                echo "Style: $(cat "$prompt_style_file") (persisted)"
            else
                echo "Style: $(_detect_prompt_style) (auto-detected)"
            fi
            [ -n "${STARSHIP_CONFIG:-}" ] && echo "Config: $STARSHIP_CONFIG"
            ;;

        # Reset to auto-detection
        auto)
            rm -f "$prompt_style_file"
            echo "Reset to auto-detection"
            setup_prompt
            ;;

        # Use fallback prompt
        off)
            mkdir -p "$(dirname "$prompt_style_file")"
            echo "off" > "$prompt_style_file"
            echo "Switched to fallback prompt"
            _setup_fallback_prompt
            ;;

        # List available styles
        list)
            _prompt_style_list
            ;;

        # Set specific style
        *)
            if [ -f "${config_dir}/${arg}.toml" ]; then
                mkdir -p "$(dirname "$prompt_style_file")"
                echo "$arg" > "$prompt_style_file"
                _set_starship_config "${config_dir}/${arg}.toml"
                echo "Switched to: $arg"
            else
                echo "Style not found: $arg"
                echo "Available: $(_get_style_names)"
                return 1
            fi
            ;;
    esac
}

# ============================================================================
# HELPERS
# ============================================================================
_get_style_names() {
    local names=""
    if [ -d "$starship_configs_dir" ]; then
        for f in "$starship_configs_dir"/*.toml; do
            [ -f "$f" ] || continue
            name="$(basename "$f" .toml)"
            names="${names:+$names, }$name"
        done
    fi
    echo "${names:-none}, off"
}

_prompt_style_list() {
    local current=""
    if [ -f "$prompt_style_file" ]; then
        current="$(cat "$prompt_style_file")"
    fi

    echo "Available prompt styles:"
    if [ -d "$starship_configs_dir" ]; then
        for f in "$starship_configs_dir"/*.toml; do
            [ -f "$f" ] || continue
            name="$(basename "$f" .toml)"
            if [ "$name" = "$current" ]; then
                echo "  * $name (active)"
            else
                echo "    $name"
            fi
        done
    fi
    echo "    off (fallback prompt)"
    echo ""
    echo "Usage: prompt-style <name>  or  prompt-style (for fzf picker)"
}

_prompt_style_fzf() {
    local styles=""
    local current=""

    if [ -f "$prompt_style_file" ]; then
        current="$(cat "$prompt_style_file")"
    fi

    # Build list of styles
    if [ -d "$starship_configs_dir" ]; then
        for f in "$starship_configs_dir"/*.toml; do
            [ -f "$f" ] || continue
            name="$(basename "$f" .toml)"
            styles="${styles}${name}\n"
        done
    fi
    styles="${styles}off\nauto"

    # Run fzf
    local selected
    selected="$(printf "%b" "$styles" | fzf --prompt="Select prompt style: " --height=10 --reverse)"

    [ -z "$selected" ] && return

    # Apply selection
    prompt-style "$selected"
}
