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