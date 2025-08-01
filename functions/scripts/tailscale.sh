#!/bin/sh

function tail-send(){
    local target="$(tailscale status | fzf | awk '{print $2}')"
    echo "Running: sudo tailscale file cp $@ $target:"
    sudo tailscale file cp $@ $target:
}

function tail-get(){
    local dr="${1:-"./"}"
    echo "Running: sudo tailscale file get $dr"
    sudo tailscale file get $dr
}