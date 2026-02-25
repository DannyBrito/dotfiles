#!/bin/sh
# Wake dev VM script - self-contained
# Ensure az CLI is in PATH (Shortcuts uses minimal PATH)
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Source credentials (for AZ_DANNY, AZ_AZCU variables)
. "$HOME/dev/danny/dotfiles/vars.env"

# Inline functions (avoid sourcing files with hyphenated functions)
az_danny() {
    az account set -s "$AZ_DANNY"
}

az_azcu() {
    az account set -s "$AZ_AZCU"
}

wake_dev_vm() {
    echo "Waking up dev VM"
    az_danny

    state="$(az vm get-instance-view -g dev-vm -n dev-vm --query "instanceView.statuses[?starts_with(code, 'PowerState/')].displayStatus | [0]" -o tsv 2>/dev/null)"
    echo "Dev VM state: ${state:-unknown}"

    case "$state" in
        "VM running")
            echo "Dev VM is already running"
            az_azcu
            return 0
            ;;
        "VM starting")
            echo "Dev VM is already starting"
            az_azcu
            return 0
            ;;
    esac

    az vm start -g dev-vm --name dev-vm

    state="$(az vm get-instance-view -g dev-vm -n dev-vm --query "instanceView.statuses[?starts_with(code, 'PowerState/')].displayStatus | [0]" -o tsv 2>/dev/null)"
    echo "Dev VM state: ${state:-unknown}"

    az_azcu
}

# Run
wake_dev_vm
