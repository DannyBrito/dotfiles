#!/bin/bash
set -euo pipefail

# Validation functions for dotfiles setup

validate_dependencies() {
    local missing_deps=()
    
    # Check for required commands
    local required_commands=("git" "curl" "ln" "mkdir" "cp")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "❌ Missing required dependencies: ${missing_deps[*]}"
        echo "Please install these dependencies and try again."
        exit 1
    fi
    
    echo "✅ All dependencies are available"
}

validate_shell() {
    if [ -z "${SHELL:-}" ]; then
        echo "❌ SHELL environment variable is not set"
        exit 1
    fi
    
    echo "✅ Shell detected: $SHELL"
}

validate_permissions() {
    local config_dir="${HOME}/.config"
    
    if [ ! -w "$HOME" ]; then
        echo "❌ No write permission to home directory: $HOME"
        exit 1
    fi
    
    if [ ! -d "$config_dir" ]; then
        mkdir -p "$config_dir" || {
            echo "❌ Cannot create config directory: $config_dir"
            exit 1
        }
    fi
    
    echo "✅ Permissions validated"
}

main() {
    echo "🔍 Validating dotfiles setup prerequisites..."
    validate_dependencies
    validate_shell
    validate_permissions
    echo "✅ All validations passed!"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
