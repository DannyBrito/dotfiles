#!/bin/sh

function git-download-artifacts(){
    local run_id="$(echo "$1" | grep -oP '(?<=runs/)\d+')"
    local outdir="${2}"
    if [[ -z "$outdir" ]]; then
        outdir="${run_id}-artifacts"
    fi
    cmd="gh run download "${run_id}" -D "${outdir}""
    echo "running: $cmd"
    $cmd
}