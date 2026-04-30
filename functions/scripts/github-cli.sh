#!/bin/sh

# Helper to extract run ID from URL
function _extract_run_id() {
    echo "$1" | sed -n 's|.*/runs/\([0-9]*\).*|\1|p'
}

# Helper to extract org from URL
function _extract_org() {
    echo "$1" | awk -F'/' '{print $4}'
}

# Helper to extract repo from URL
function _extract_repo() {
    echo "$1" | awk -F'/' '{print $5}'
}

function gh-download-artifacts(){
    local run_id="$(_extract_run_id "$1")"
    local outdir="${2}"
    if [ -z "$outdir" ]; then
        outdir="gh-artifacts-${run_id}"
    fi
    echo "running: gh run download \"${run_id}\" -D \"${outdir}\""
    gh run download "${run_id}" -D "${outdir}"
}

function gh-cancel-workflow-run(){
    # example input:
    # https://github.com/org/repo/actions/runs/19304486932/job/55210925922?pr=2769
    local url="$1"
    local run_id="$(_extract_run_id "$url")"
    local org="$(_extract_org "$url")"
    local repo="$(_extract_repo "$url")"
    echo "Cancelling workflow run via force API: $run_id"
    gh api --method POST -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" /repos/${org}/${repo}/actions/runs/${run_id}/force-cancel
}

function gh-pr-web(){
    # Opens GitHub PR creation page, prompting for remote if multiple exist
    local remotes=($(git remote))
    if [[ ${#remotes[@]} -eq 0 ]]; then
        echo "No remotes found" >&2
        return 1
    elif [[ ${#remotes[@]} -eq 1 ]]; then
        gh pr create --web -R "$(git remote get-url "${remotes[0]}")"
    else
        local remote
        remote=$(printf '%s\n' "${remotes[@]}" | fzf --prompt="Select remote for PR: ")
        [[ -z "$remote" ]] && return 1
        gh pr create --web -R "$(git remote get-url "$remote")"
    fi
}

function gh-pr-web-auto(){
    # Opens GitHub PR creation page, auto-selecting remote: upstream > origin > only-one > fail
    local remotes=($(git remote))
    local branch=$(git branch --show-current)

    if [[ ${#remotes[@]} -eq 0 ]]; then
        echo "No remotes found" >&2
        return 1
    elif [[ ${#remotes[@]} -eq 1 ]]; then
        gh pr create --web
    elif git remote get-url upstream &>/dev/null && git remote get-url origin &>/dev/null; then
        # Fork workflow: origin is fork, upstream is target
        local origin_url=$(git remote get-url origin)
        local fork_owner=$(echo "$origin_url" | sed -E 's|.*[:/]([^/]+)/[^/]+(.git)?$|\1|')
        gh pr create --web -R "$(git remote get-url upstream)" --head "${fork_owner}:${branch}"
    elif git remote get-url upstream &>/dev/null; then
        gh pr create --web -R "$(git remote get-url upstream)"
    elif git remote get-url origin &>/dev/null; then
        gh pr create --web -R "$(git remote get-url origin)"
    else
        echo "Multiple remotes found but no 'upstream' or 'origin'. Use gh-pr-web to select." >&2
        return 1
    fi
}

function gh-pr-view-web(){
    # Opens the PR associated with the current branch in the browser
    gh pr view --web
}