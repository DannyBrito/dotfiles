#!/usr/bin/env zsh
# Backup and restore system for macOS preferences
# Saves current state before applying changes, allows rollback

# Guard against multiple sourcing
[[ -n "${_MACOS_PREFS_BACKUP_LOADED:-}" ]] && return 0
_MACOS_PREFS_BACKUP_LOADED=1

set -euo pipefail

# Get the directory of THIS file (works when sourced)
_BACKUP_LIB_DIR="${${(%):-%x}:a:h}"
source "${_BACKUP_LIB_DIR}/core.sh"

# Default backup directory
BACKUP_BASE_DIR="${HOME}/.macos-prefs-backup"

# Initialize backup directory
init_backup_dir() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR="${BACKUP_BASE_DIR}/${timestamp}"
    mkdir -p "${BACKUP_DIR}"
    echo "${BACKUP_DIR}"
}

# Get latest backup directory
get_latest_backup() {
    if [[ -d "${BACKUP_BASE_DIR}" ]]; then
        ls -1d "${BACKUP_BASE_DIR}"/*/ 2>/dev/null | sort -r | head -n1 | sed 's:/$::'
    fi
}

# List all backups
list_backups() {
    if [[ -d "${BACKUP_BASE_DIR}" ]]; then
        log_section "Available Backups"
        local count=0
        while IFS= read -r backup; do
            if [[ -n "$backup" ]]; then
                local name=$(basename "$backup")
                local date_part="${name:0:8}"
                local time_part="${name:9:6}"
                local formatted_date="${date_part:0:4}-${date_part:4:2}-${date_part:6:2}"
                local formatted_time="${time_part:0:2}:${time_part:2:2}:${time_part:4:2}"

                # Count files in backup
                local file_count=$(find "$backup" -type f | wc -l | tr -d ' ')

                echo "  ${count}. ${formatted_date} ${formatted_time} (${file_count} files) - ${backup}"
                count=$((count + 1))
            fi
        done < <(ls -1d "${BACKUP_BASE_DIR}"/*/ 2>/dev/null | sort -r)

        if [[ $count -eq 0 ]]; then
            log_info "No backups found"
        fi
    else
        log_info "No backup directory found"
    fi
}

# Backup a single defaults domain
backup_defaults_domain() {
    local domain="$1"
    local backup_dir="${2:-${BACKUP_DIR:-}}"

    # Skip if no backup directory is set
    [[ -z "$backup_dir" ]] && return 0

    local filename

    # Sanitize domain name for filename
    filename=$(echo "$domain" | tr '/' '_')

    local backup_file="${backup_dir}/defaults/${filename}.plist"
    mkdir -p "$(dirname "$backup_file")"

    if defaults export "$domain" - > "$backup_file" 2>/dev/null; then
        return 0
    else
        # Domain doesn't exist yet, create empty marker
        echo "# Domain did not exist" > "${backup_file}.empty"
        return 0
    fi
}

# Full backup of common preference domains
backup_all_preferences() {
    local backup_dir=$(init_backup_dir)

    log_section "Creating Full Preference Backup"
    log_info "Backup location: $backup_dir"

    # Create metadata file
    cat > "${backup_dir}/metadata.json" <<EOF
{
    "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "macos_version": "$(get_macos_version)",
    "macos_name": "$(get_macos_name)",
    "hostname": "$(hostname)",
    "user": "$(whoami)"
}
EOF

    # Backup common preference domains
    local domains=(
        "NSGlobalDomain"
        "com.apple.finder"
        "com.apple.dock"
        "com.apple.screencapture"
        "com.apple.desktopservices"
        "com.apple.LaunchServices"
        "com.apple.terminal"
        "com.apple.CrashReporter"
        "com.apple.print.PrintingPrefs"
        "com.apple.NetworkBrowser"
        "com.apple.driver.AppleBluetoothMultitouch.trackpad"
        "com.googlecode.iterm2"
        "com.apple.ActivityMonitor"
    )

    for domain in "${domains[@]}"; do
        backup_defaults_domain "$domain" "$backup_dir"
        log_success "Backed up domain: $domain"
    done

    log_success "Backup complete: $backup_dir"
    echo "$backup_dir"
}

# Restore from a backup
restore_defaults_domain() {
    local domain="$1"
    local backup_dir="$2"

    local filename=$(echo "$domain" | tr '/' '_')
    local backup_file="${backup_dir}/defaults/${filename}.plist"
    local empty_marker="${backup_file}.empty"

    if [[ -f "$empty_marker" ]]; then
        # Domain didn't exist, delete it
        defaults delete "$domain" 2>/dev/null || true
        log_success "Removed domain: $domain (didn't exist before)"
        return 0
    elif [[ -f "$backup_file" ]]; then
        # Delete domain first, then import (true replacement, not merge)
        defaults delete "$domain" 2>/dev/null || true
        if defaults import "$domain" "$backup_file" 2>/dev/null; then
            log_success "Restored domain: $domain"
            return 0
        else
            log_error "Failed to restore: $domain"
            return 1
        fi
    else
        log_warning "No backup found for: $domain"
        return 1
    fi
}

# Full restore from backup
restore_all_from_backup() {
    local backup_dir="${1:-$(get_latest_backup)}"

    if [[ -z "$backup_dir" ]] || [[ ! -d "$backup_dir" ]]; then
        log_error "No valid backup found"
        return 1
    fi

    log_section "Restoring from Backup"
    log_info "Backup: $backup_dir"

    # Show metadata
    if [[ -f "${backup_dir}/metadata.json" ]]; then
        log_info "Backup metadata:"
        cat "${backup_dir}/metadata.json"
        echo
    fi

    # Confirm
    echo -n "Restore all preferences from this backup? [y/N] "
    read -r confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        log_info "Restore cancelled"
        return 0
    fi

    # Close System Settings
    quit_app "System Settings"
    quit_app "System Preferences"

    # Restore all domains
    if [[ -d "${backup_dir}/defaults" ]]; then
        for plist in "${backup_dir}/defaults"/*.plist; do
            if [[ -f "$plist" ]]; then
                local filename=$(basename "$plist" .plist)
                local domain=$(echo "$filename" | tr '_' '/')
                restore_defaults_domain "$domain" "$backup_dir"
            fi
        done
    fi

    # Restart affected apps
    log_info "Restarting affected applications..."
    kill_system_apps "Dock" "Finder" "SystemUIServer"

    log_success "Restore complete! Some changes may require logout/restart."
}
