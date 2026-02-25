#!/bin/sh

# AZ CLI
function az-login(){
    echo "Running: az login --use-device-code"
    az login --use-device-code
}

function az-who(){
    echo "Running: az account show --query name"
    az account show --query name
}

function az-clean(){
    echo "Running script ${config_dir}/scripts/delete-groups.sh"
    . ${config_dir}/scripts/delete-groups.sh
}

function acr-login(){
    local account="${1:-$cr}"
    echo "az acr login -n $account"
    az acr login -n $account
}

function az-set(){
    az account set -s "$1"
}