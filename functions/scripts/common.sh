#!/bin/sh

# cd-directories
alias cd-dev="cd ${dev_dir}"
alias cd-config="cd ${config_dir}"
alias cd-dotfiles="cd ${_dotfiles_dir}"

# Navigate up directories
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -="cd -"

# programs/binaries aliases
alias g="git"
alias k="kubectl"
alias d="docker"

# code quick open
alias ecalias="code ${alias_scripts_dir}/bash"
alias ecgit="code ${alias_scripts_dir}/git"
alias ecbashrc="code ${HOME}/.bashrc"
alias eczshrc="code ${HOME}/.zshrc"

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'

# Grep with color
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Cleanup .DS_Store files
alias cleanup_ds="find . -type f -name '*.DS_Store' -ls -delete"
alias cc="clear"

# Enable aliases to be sudo'ed
alias sudo='sudo '

function git-cred(){
    if [[ -e "${config_dir}/cred.env" ]]; then
        export $(xargs <${config_dir}/cred.env)
    else
        echo "no cred.env found"
    fi
}

function disk-usage(){
    local params="$@"
    if [[ -z $params ]]; then
        params="-h --max-depth=1 ."
    fi
    echo "Disk usage: running du $params"
    du $params
}

function disk-usage-all(){
    echo "Disk usage: running df -h $@"
    df -h $@
}

function src-envfile(){
    local file="${1:-.env}"
    if [[ ! -e $file ]]; then
        echo "file not found: $file"
        return 1
    fi
    export $(awk -F= '/^[^#]/ {split($2, a, " #"); print $1"="a[1]}' $file)
}

function bat_fallback() {
    if command -v bcat > /dev/null 2>&1; then
        bcat "$@"
    elif command -v bat > /dev/null 2>&1 && [ "$(command -v bat)" != "$(alias bat)" ]; then
        bat "$@"
    elif command -v batcat > /dev/null 2>&1; then
        batcat "$@"
    elif command -v cat > /dev/null 2>&1; then
        cat "$@"
    else
        echo "error"
        return 1
    fi
}

alias bat='bat_fallback'

# functions
function lsa(){
    echo "Running: ls -a"
    ls -a
}

function xx(){
    echo "Running: exit 0"
    exit 0
}

function sh-restart(){
    exec $SHELL
}

# check given vs calculated
# example: checksum 69274fd3b9e65b39e33070376400b7e31664388cdee012591fabc849bee4258e kubernetes.tar.gz
function checksum(){
    if [ -z "$1" || -z "$2" ]; then
        echo "usage: checksum <sha-num> <file> (e.g checksum 6...e k8s.tar.gz)"
        exit 1
    fi
    local given=$1
    local fileToCheck=$2
    echo "$given $fileToCheck" | sha256sum -c
}

function server() {
    local port="${1:-8000}"
    sleep 1 && open "http://localhost:${port}/" &
    # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
    # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
    python3 -c $'import http.server;\nmap = http.server.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nhttp.server.test(HandlerClass=http.server.SimpleHTTPRequestHandler, port=int('$port'))'
}

function tar-extract() {
    local file="${1:-src.tar.gz}"
    local dest="${2:-.}"
    if [[ ! -e "$file" ]]; then
        echo "file not found: $file"
        return 1
    fi
    # Check if destination exists, create if not
    if [[ ! -d "$dest" ]]; then
        echo "Destination '$dest' does not exist. Creating..."
        mkdir -p "$dest"
    fi
    echo "Extracting tar file: $file to $dest"
    # Detect if file is gzipped
    if [[ "$file" == *.tar.gz || "$file" == *.tgz ]]; then
        tar -xzf "$file" -C "$dest"
    else
        tar -xf "$file" -C "$dest"
    fi
}

function tar-create() {
    local src="${1:-.}"
    local dest="${2:-archive.tar.gz}"
    echo "Creating tar.gz file: $dest from $src"
    tar -czf "$dest" -C "$(dirname "$src")" "$(basename "$src")"
}