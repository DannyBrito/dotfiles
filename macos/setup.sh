#!/usr/bin/env zsh
#
# macOS Preferences Setup
# All settings individually toggleable, all OFF by default
#
# Usage:
#   ./setup.sh              # Interactive mode - toggle settings
#   ./setup.sh --all        # Enable and apply ALL settings
#   ./setup.sh --list       # List all settings with status
#   ./setup.sh --backup     # Create backup only
#   ./setup.sh --restore    # Restore from backup
#   ./setup.sh --help       # Show help

set -euo pipefail

SCRIPT_DIR="${0:a:h}"
PREFS_DIR="${SCRIPT_DIR}/prefs"
LIB_DIR="${PREFS_DIR}/lib"

# Source libraries
source "${LIB_DIR}/core.sh"
source "${LIB_DIR}/backup.sh"
source "${PREFS_DIR}/settings.sh"

# Display version and system info
show_system_info() {
    echo "${BOLD}macOS Preferences Setup${NC}"
    echo "macOS $(get_macos_version) ($(get_macos_name))"
    echo "Architecture: $(uname -m)"
    if is_sip_enabled; then
        echo "SIP: ${GREEN}Enabled${NC}"
    else
        echo "SIP: ${YELLOW}Disabled${NC}"
    fi
    echo
}

# Show help
show_help() {
    cat << 'EOF'
macOS Preferences Setup

All settings individually toggleable. All OFF by default.

USAGE:
    ./setup.sh [OPTIONS]

OPTIONS:
    (no options)      Interactive menu - choose action
    --all             Enable and apply ALL settings
    --list            List all available settings
    --backup          Create backup only (no changes applied)
    --restore [PATH]  Restore from backup (latest or specified path)
    --list-backups    Show all available backups
    --no-backup       Skip backup before applying changes
    --help, -h        Show this help message

EXAMPLES:
    ./setup.sh                   # Show interactive menu
    ./setup.sh --all             # Apply everything
    ./setup.sh --list            # See all available settings
    ./setup.sh --backup          # Backup current preferences
    ./setup.sh --restore         # Restore from latest backup
EOF
}

# Interactive picker
run_interactive() {
    local total=${#SETTINGS_ORDER[@]}
    local current=1
    local scroll_offset=0
    local term_lines=$(tput lines)
    local max_visible=$((term_lines - 8))

    # Hide cursor
    tput civis
    trap 'tput cnorm; echo' EXIT INT TERM

    while true; do
        clear
        echo "${BOLD}macOS Preferences Setup${NC}"
        echo "Use ↑/↓ to navigate, SPACE to toggle, ENTER to apply, q to quit"
        echo "Enabled: $(count_enabled_settings)/${total}"
        echo "─────────────────────────────────────────────────────────────"

        # Calculate scroll window
        if [[ $current -gt $((scroll_offset + max_visible)) ]]; then
            scroll_offset=$((current - max_visible))
        elif [[ $current -le $scroll_offset ]]; then
            scroll_offset=$((current - 1))
        fi

        local displayed=0
        local idx=1
        for id in "${SETTINGS_ORDER[@]}"; do
            if [[ $idx -gt $scroll_offset ]] && [[ $displayed -lt $max_visible ]]; then
                local desc=$(get_setting_desc "$id")
                local mark="[ ]"
                [[ "${SETTINGS_ENABLED[$id]}" == "1" ]] && mark="${GREEN}[✓]${NC}"

                local sudo_marker=""
                setting_needs_sudo "$id" && sudo_marker=" ${YELLOW}(sudo)${NC}"

                if [[ $idx -eq $current ]]; then
                    echo "${REVERSE} ${mark} ${desc}${sudo_marker} ${NC}"
                else
                    echo " ${mark} ${desc}${sudo_marker}"
                fi
                displayed=$((displayed + 1))
            fi
            idx=$((idx + 1))
        done

        # Read key
        local key=""
        IFS= read -rsk1 key || key=""
        case "$key" in
            $'\x1b')  # Escape sequence
                local rest=""
                read -rsk2 rest 2>/dev/null || rest=""
                case "$rest" in
                    '[A') [[ $current -gt 1 ]] && current=$((current - 1)) ;;  # Up
                    '[B') [[ $current -lt $total ]] && current=$((current + 1)) ;;  # Down
                esac
                ;;
            ' ')  # Space - toggle
                local id="${SETTINGS_ORDER[$current]}"
                toggle_setting "$id"
                ;;
            'a'|'A')  # Enable all
                enable_all_settings
                ;;
            'n'|'N')  # Disable all
                for id in "${SETTINGS_ORDER[@]}"; do
                    disable_setting "$id"
                done
                ;;
            ''|$'\n')  # Enter - apply
                tput cnorm
                break
                ;;
            'q'|'Q')  # Quit
                tput cnorm
                echo "Cancelled."
                return 1
                ;;
        esac
    done

    return 0
}

# Apply selected settings
apply_settings() {
    local skip_backup="${1:-false}"
    local enabled_count=$(count_enabled_settings)

    if [[ $enabled_count -eq 0 ]]; then
        log_warning "No settings enabled. Nothing to apply."
        return 0
    fi

    echo
    log_section "Applying ${enabled_count} Settings"

    # Request sudo if needed
    if any_settings_need_sudo; then
        log_info "Some settings require administrator privileges."
        sudo -v || { log_error "Sudo required for some settings"; return 1; }
        # Keep sudo alive
        while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    fi

    # Create backup unless skipped
    if [[ "$skip_backup" != "true" ]]; then
        log_section "Creating Backup"
        backup_all_preferences
    fi

    # Apply settings
    echo
    apply_enabled_settings

    # Restart affected apps
    echo
    log_section "Restarting Affected Applications"
    for app in "Dock" "Finder" "SystemUIServer"; do
        killall "$app" &>/dev/null || true
    done
    log_success "Applications restarted"

    echo
    log_success "Done! Some changes may require logout/restart."
}

# Main
main() {
    local action=""
    local skip_backup=false
    local restore_path=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_help
                return 0
                ;;
            --list)
                action="list"
                ;;
            --all)
                action="all"
                ;;
            --backup)
                action="backup"
                ;;
            --restore)
                action="restore"
                if [[ -n "${2:-}" ]] && [[ ! "$2" =~ ^-- ]]; then
                    restore_path="$2"
                    shift
                fi
                ;;
            --list-backups)
                action="list-backups"
                ;;
            --no-backup)
                skip_backup=true
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                return 1
                ;;
        esac
        shift
    done

    # Handle actions
    case "$action" in
        list)
            log_section "All Available Settings (${#SETTINGS_ORDER[@]} total)"
            echo "All settings are OFF by default. Use interactive mode to enable."
            echo
            list_all_settings
            ;;
        all)
            show_system_info
            enable_all_settings
            apply_settings "$skip_backup"
            ;;
        backup)
            log_section "Creating Full Preference Backup"
            backup_all_preferences
            ;;
        restore)
            log_section "Restoring from Backup"
            if [[ -n "$restore_path" ]]; then
                restore_all_from_backup "$restore_path"
            else
                local latest=$(get_latest_backup)
                if [[ -z "$latest" ]]; then
                    log_error "No backups found"
                    return 1
                fi
                restore_all_from_backup "$latest"
            fi
            ;;
        list-backups)
            log_section "Available Backups"
            list_backups
            ;;
        *)
            # Show main menu
            show_main_menu
            ;;
    esac
}

# Main menu
show_main_menu() {
    while true; do
        clear
        echo "${BOLD}macOS Preferences Setup${NC}"
        echo "macOS $(get_macos_version) ($(get_macos_name))"
        echo
        echo "What would you like to do?"
        echo
        echo "  ${BOLD}1${NC}) Configure preferences (select settings to apply)"
        echo "  ${BOLD}2${NC}) List all available settings"
        echo "  ${BOLD}3${NC}) Create backup"
        echo "  ${BOLD}4${NC}) List backups"
        echo "  ${BOLD}5${NC}) Restore from backup"
        echo "  ${BOLD}q${NC}) Quit"
        echo
        echo -n "Choice [1-5/q]: "

        local choice=""
        read -r choice

        case "$choice" in
            1)
                show_system_info
                if run_interactive; then
                    apply_settings false
                fi
                echo
                echo -n "Press Enter to continue..."
                read -r
                ;;
            2)
                clear
                log_section "All Available Settings (${#SETTINGS_ORDER[@]} total)"
                echo "All settings are OFF by default."
                echo
                list_all_settings
                echo
                echo -n "Press Enter to continue..."
                read -r
                ;;
            3)
                clear
                log_section "Creating Full Preference Backup"
                backup_all_preferences
                echo
                echo -n "Press Enter to continue..."
                read -r
                ;;
            4)
                clear
                log_section "Available Backups"
                list_backups
                echo
                echo -n "Press Enter to continue..."
                read -r
                ;;
            5)
                clear
                log_section "Restore from Backup"
                list_backups
                echo
                echo -n "Enter backup number (or path), or 'c' to cancel: "
                local backup_choice=""
                read -r backup_choice

                if [[ "$backup_choice" == "c" || -z "$backup_choice" ]]; then
                    continue
                fi

                # If it's a number, get the path from list
                if [[ "$backup_choice" =~ ^[0-9]+$ ]]; then
                    local backup_path=$(get_backup_by_index "$backup_choice")
                    if [[ -n "$backup_path" ]]; then
                        restore_all_from_backup "$backup_path"
                    else
                        log_error "Invalid backup number"
                    fi
                elif [[ -d "$backup_choice" ]]; then
                    restore_all_from_backup "$backup_choice"
                else
                    log_error "Invalid backup path"
                fi
                echo
                echo -n "Press Enter to continue..."
                read -r
                ;;
            q|Q)
                echo "Goodbye!"
                return 0
                ;;
            *)
                ;;
        esac
    done
}

# Get backup path by index number
get_backup_by_index() {
    local index="$1"
    local count=0

    if [[ -d "${BACKUP_BASE_DIR:-$HOME/.macos-prefs-backup}" ]]; then
        while IFS= read -r backup; do
            if [[ $count -eq $index ]]; then
                echo "$backup"
                return 0
            fi
            count=$((count + 1))
        done < <(ls -1d "${BACKUP_BASE_DIR:-$HOME/.macos-prefs-backup}"/*/ 2>/dev/null | sort -r)
    fi
    return 1
}

main "$@"
