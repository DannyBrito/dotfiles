#!/bin/sh
# Project navigation and management functions

function pickpathdir(){
    cat ${config_dir}/${projects_txt} | \
        fzf --preview 'ls -1 $(echo {} | awk "{print \$2}")' \
            --preview-window=right:40% | awk '{print $2}'
}

function cdx(){
    local target
    if [ -n "$1" ]; then
        target="$(_reverse_path_completion $1)"
    else
        target="$(pickpathdir)"
    fi
    [ -z "$target" ] && return 1
    [ ! -d "$target" ] && echo "Directory not found: $target" && return 1
    cd "$target"
}

function vsx(){
    local target
    if [ -n "$1" ]; then
        target="$(_reverse_path_completion $1)"
    else
        target="$(pickpathdir)"
    fi
    [ -z "$target" ] && return 1
    [ ! -d "$target" ] && echo "Directory not found: $target" && return 1
    code "$target"
}

function _reverse_path_completion(){
    cat $config_dir/${projects_txt} | grep -iE "^$1" | head -1 | awk '{print $2}'
}

# Add current directory to project refs
function px-add(){
    local name="${1:-$(basename $PWD)}"
    local refs_file="${config_dir}/${projects_txt}"
    # Check if already exists
    if grep -q "^$name " "$refs_file" 2>/dev/null; then
        echo "Project '$name' already exists"
        return 1
    fi
    echo "$name $PWD" >> "$refs_file"
    echo "Added: $name -> $PWD"
}

# Remove project from refs
function px-rm(){
    local name="$1"
    local refs_file="${config_dir}/${projects_txt}"
    [ -z "$name" ] && name="$(cat "$refs_file" | fzf | awk '{print $1}')"
    [ -z "$name" ] && return 1
    if grep -q "^$name " "$refs_file" 2>/dev/null; then
        grep -v "^$name " "$refs_file" > "${refs_file}.tmp" && mv "${refs_file}.tmp" "$refs_file"
        echo "Removed: $name"
    else
        echo "Project '$name' not found"
        return 1
    fi
}

# List all project refs
function px-ls(){
    cat ${config_dir}/${projects_txt} | column -t
}

# AUTOCOMPLETE FUNCTIONS
if [ -n "$BASH_VERSION" ]; then
    _pickpathdir_completion() {
        local paths_file="${config_dir}/${projects_txt}"
        local cur=${COMP_WORDS[COMP_CWORD]}
        COMPREPLY=($(cat "$paths_file" | grep -o '^[^ ]*' | grep "^$cur"))
    }
    complete -F _pickpathdir_completion cdx vsx
elif [ -n "$ZSH_VERSION" ]; then
    _pickpathdir_completion() {
        local paths_file="${config_dir}/${projects_txt}"
        compadd $(cat "$paths_file" | grep -o '^[^ ]*')
    }
    compdef _pickpathdir_completion cdx vsx
fi
