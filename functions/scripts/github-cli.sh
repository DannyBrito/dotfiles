#!/bin/sh

function gh-download-artifacts(){
    local run_id="$(echo "$1" | grep -oP '(?<=runs/)\d+')"
    local outdir="${2}"
    if [[ -z "$outdir" ]]; then
        outdir="gh-artifacts-${run_id}"
    fi
    cmd="gh run download "${run_id}" -D "${outdir}""
    echo "running: $cmd"
    $cmd
}

function gh-cancel-workflow-run(){
    # example input:
    # https://github.com/org/repo/actions/runs/19304486932/job/55210925922?pr=2769
    local url="$1"
    local run_id="$(echo "$url" | grep -oP '(?<=runs/)\d+')"
    local org="$(echo "$url" | awk -F'/' '{print $4}')"
    local repo="$(echo "$url" | awk -F'/' '{print $5}')"
    echo "Cancelling workflow run via force API: $run_id"
    gh api --method POST -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" /repos/${org}/${repo}/actions/runs/${run_id}/force-cancel
}