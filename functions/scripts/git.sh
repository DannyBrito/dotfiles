#!/bin/sh

function gri (){
    echo "Running: git rebase -i HEAD~$1"
    git rebase -i HEAD~$1
}

function git-code-editor(){
    local code_git="code --wait"
    echo "Toggling code as git editor variable"
    if [ "$GIT_EDITOR" = "$code_git" ]; then
        unset GIT_EDITOR
    else
        export GIT_EDITOR="$code_git"
    fi
}

function glo (){
    echo "Running: git log --oneline"
    git log --oneline
}

function glon (){
    echo "Running: git log --oneline --color | nl -v 1 | less -R"
    git log --oneline --color | nl -v 1 | less -FXR
}

function glg (){
    echo "Running: git log --graph"
    git log --graph
}

function gfo (){
    gfetch "origin"
    echo "updated"
}

function ggonels(){
    git branch --v | grep "\[gone\]"
}

function ggonedelete(){
    ggonels | awk '{print $1}' | xargs git branch -D
}
function gfetch (){
    local remote="${1:-origin}"
    echo "Running: git fetch $remote"
    git fetch "$remote"
}

function grls (){
    echo "Running: git remote -v"
    git remote -v
}

function gfr(){
    local main_branch="$(git_default_branch)"
    local remote="${1:-origin}"
    echo "Running: git fetch $remote and rebase $remote/$main_branch"
    gfetch "$remote"
    git rebase "$remote/$main_branch"
}

function gfpr(){
    local main_branch="$(git_default_branch)"
    local remote="${1:-origin}"
    echo "Running: git fetch --prune $remote and rebase $remote/$main_branch"
    gfp "$remote"
    git rebase "$remote/$main_branch"
}

function gfp(){
    local remote="${1:-origin}"
    echo "Running: git fetch --prune $remote"
    git fetch --prune $remote
}

function gbn(){
    local branch="$1"
    echo "Running: git checkout -b $branch $2"
    case "$branch" in
        *:*) branch="${branch#*:}" ;;
    esac
    git checkout -b $branch $2
}

function greturn(){
    local git_dir="$(git rev-parse --show-toplevel)"
    echo "returning to '${git_dir}'"
    cd "${git_dir}"
}

function git_default_branch (){
    # git branch | cut -c 3- | grep -E '^master$|^main$'
    git rev-parse --abbrev-ref origin/HEAD | cut -d '/' -f 2
}

function gcod(){
    local main_branch="$(git_default_branch)"
    echo "Running: git checkout to default branch -> $main_branch"
    git checkout $main_branch
}

# Toggle signoff for this repository
function git-toggle-signoff(){
    local current=$(git config --local --get commit.signoff 2>/dev/null)
    if [ "$current" = "true" ]; then
        git config --local --unset commit.signoff
        echo "✗ Signoff (DCO) DISABLED for this repo"
    else
        git config --local commit.signoff true
        echo "✓ Signoff (DCO) ENABLED for this repo"
    fi
}

# Helper to check if signoff is enabled
function _git_should_signoff(){
    local signoff=$(git config --get commit.signoff 2>/dev/null)
    if [ "$signoff" = "true" ]; then
        echo "--signoff"
    else
        echo ""
    fi
}

function git-useconfig(){
    git config --global user.useconfigonly "true"
}

function git-enable-signing-local(){
    if [ -n "${1}" ] && [[ "${1}" == *".pub" ]] && [ ! -f "${1}" ]; then
        echo "Error: Signing key file '${1}' does not exist."
        return 1
    fi
    echo "Enabling GPG commit signing locally with key: ${1}"
    git config --local gpg.format ssh
    git config --local user.signingkey ${1}
    git config --local commit.gpgsign true
}

function gcam(){
    local msg=${1:-"fix"}
    local signoff_flag="$(_git_should_signoff)"
    echo "Running: git commit -am '$msg' $signoff_flag"
    git commit -am "$msg" $signoff_flag
}

function gcm(){
    local msg=${1:-"fix"}
    local signoff_flag="$(_git_should_signoff)"
    echo "Running: git commit -m '$msg' $signoff_flag"
    git commit -m "$msg" $signoff_flag
}

function gcamnoverify(){
    local msg=${1:-"fix"}
    local signoff_flag="$(_git_should_signoff)"
    echo "Running: git commit -am '$msg' --no-verify $signoff_flag"
    git commit -am "$msg" --no-verify $signoff_flag
}

function gcmnoverify(){
    local msg=${1:-"fix"}
    local signoff_flag="$(_git_should_signoff)"
    echo "Running: git commit -m '$msg' --no-verify $signoff_flag"
    git commit -m "$msg" --no-verify $signoff_flag
}

function gall(){
    echo "Running: git add ."
    git add .
}

function gs(){
    echo "Running: git status"
    git status
}

function gredo(){
    git reset --soft HEAD~1
    gamend
}

function gco(){
    local branch="$1"
    if [ -z "$branch" ]; then
        branch="$( git branch -l --format='%(refname:short)' | fzf)"
    fi
    case "$branch" in
        *:*) branch="${branch#*:}" ;;
    esac
    if [ -z "$branch" ]; then
        echo "Cancel none picked"
        return 1
    fi
    echo "Running: git checkout $branch"
    git checkout $branch
}

function gamend(){
    local msg="$1"
    local signoff_flag="$(_git_should_signoff)"
    if [ -n "$msg" ]; then
        echo "Running: git commit --amend -m '$msg' $signoff_flag"
        git commit --amend -m "$msg" $signoff_flag
    else
        echo "Running: git commit --amend --no-edit $signoff_flag"
        git commit --amend --no-edit $signoff_flag
    fi
}

function gamendnoverify(){
    local msg="$1"
    local signoff_flag="$(_git_should_signoff)"
    if [ -n "$msg" ]; then
        echo "Running: git commit --amend -m '$msg' --no-verify $signoff_flag"
        git commit --amend -m "$msg" --no-verify $signoff_flag
    else
        echo "Running: git commit --amend --no-edit --no-verify $signoff_flag"
        git commit --amend --no-edit --no-verify $signoff_flag
    fi
}

function gamendall(){
    gall
    gamend "$1"
}

function gamendallnoverify(){
    gall
    gamendnoverify "$1"
}

function git-shit(){
    local head="${1:-1}"
    echo "Running: git reset --soft HEAD~$head"
    git reset --soft HEAD~$head
}

function git-wipe(){
    local head="${1:-1}"
    echo "Running: git reset --mixed HEAD~$head"
    git reset --mixed HEAD~$head
}

function git-nuke(){
    local head="${1:-1}"
    echo "Running: git reset --hard HEAD~$head"
    git reset --hard HEAD~$head
}

function git-clean(){
    echo "Running: git reset --hard HEAD && git clean -fd"
    git reset --hard HEAD && git clean -fd
}

function gbf(){
    local inp=${1:-"."}
    git branch -a | grep "$inp"
}

function git-delete-branch-full() {
    local branch_name="$1"
    if [ -z "$branch_name" ]; then
        branch_name="$( git branch -l --format='%(refname:short)' | fzf)"
    fi
    if [ -z "$branch_name" ]; then
        echo "Cancel none picked"
        return 1
    fi
    case "$branch_name" in
        master|main)
            echo "not allowed"
            return 1
            ;;
    esac
    local remote_name="${2:-origin}"
    echo "Deleting '$branch_name', locally and from remote: $remote_name"
    git push "$remote_name" --delete "$branch_name"
    git branch -D "$branch_name"
}

function git-who-env() {
    echo "GIT_AUTHOR_EMAIL: '${GIT_AUTHOR_EMAIL}'"
}

function git-unset-email(){
    unset GIT_AUTHOR_EMAIL
    unset GIT_COMMITTER_EMAIL
}

function gdiff(){
    git diff --name-only --relative --diff-filter=d | xargs bat --diff
}

# AUTO_COMPLETES FUNCTIONS (shell-aware):
if [ -n "$BASH_VERSION" ]; then
    _gitremotes_completion() {
        local cur=${COMP_WORDS[COMP_CWORD]}
        COMPREPLY=($(git remote | grep "^$cur"))
    }
    complete -F _gitremotes_completion gfr gfpr gfp gfetch
elif [ -n "$ZSH_VERSION" ]; then
    _gitremotes_completion() {
        compadd $(git remote)
    }
    compdef _gitremotes_completion gfr gfpr gfp gfetch
fi