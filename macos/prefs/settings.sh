#!/usr/bin/env zsh
# All macOS preferences - flat list, all OFF by default
# Source guard
[[ -n "${_SETTINGS_SOURCED:-}" ]] && return 0
typeset -g _SETTINGS_SOURCED=1

# ============================================================================
# SETTINGS REGISTRY
# Each setting: ID -> "description|command|needs_sudo"
# ============================================================================
typeset -gA ALL_SETTINGS
typeset -ga SETTINGS_ORDER
typeset -gA SETTINGS_ENABLED

# Initialize all settings as disabled
init_settings() {
    # General UI/UX
    ALL_SETTINGS[save_to_disk]="Save to disk (not iCloud) by default|defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false|false"
    ALL_SETTINGS[quit_printer_app]="Auto-quit printer app when jobs complete|defaults write com.apple.print.PrintingPrefs 'Quit When Finished' -bool true|false"
    ALL_SETTINGS[disable_app_quarantine]="Disable 'Are you sure you want to open?' dialog|defaults write com.apple.LaunchServices LSQuarantine -bool false|false"
    ALL_SETTINGS[clean_open_with]="Remove duplicates in 'Open With' menu|/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user|false"
    ALL_SETTINGS[disable_crash_reporter]="Disable crash reporter dialog|defaults write com.apple.CrashReporter DialogType -string 'none'|false"
    ALL_SETTINGS[login_window_info]="Show IP/hostname on login window clock|sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName|true"

    # Input Devices
    ALL_SETTINGS[trackpad_right_click]="Trackpad: bottom right corner = right-click|defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2 && defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true && defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1 && defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true|false"
    ALL_SETTINGS[disable_media_keys]="Stop iTunes/Music from media key response|launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2>/dev/null || true|false"
    ALL_SETTINGS[fast_key_repeat]="Fast keyboard repeat rate|defaults write NSGlobalDomain KeyRepeat -int 1 && defaults write NSGlobalDomain InitialKeyRepeat -int 10|false"
    ALL_SETTINGS[disable_press_hold]="Disable press-and-hold for key repeat|defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false|false"

    # Energy
    ALL_SETTINGS[remove_sleep_image]="Remove sleep image to save disk space|sudo rm -f /private/var/vm/sleepimage && sudo touch /private/var/vm/sleepimage && sudo chflags uchg /private/var/vm/sleepimage|true"

    # Screenshots
    ALL_SETTINGS[screenshots_desktop]="Save screenshots to Desktop|defaults write com.apple.screencapture location -string \"\${HOME}/Desktop\"|false"
    ALL_SETTINGS[screenshots_png]="Screenshots in PNG format|defaults write com.apple.screencapture type -string 'png'|false"
    ALL_SETTINGS[screenshots_no_shadow]="Disable shadow in screenshots|defaults write com.apple.screencapture disable-shadow -bool true|false"

    # Finder
    ALL_SETTINGS[finder_desktop_default]="Finder: new windows open Desktop|defaults write com.apple.finder NewWindowTarget -string 'PfDe' && defaults write com.apple.finder NewWindowTargetPath -string \"file://\${HOME}/Desktop/\"|false"
    ALL_SETTINGS[finder_show_extensions]="Finder: show all file extensions|defaults write NSGlobalDomain AppleShowAllExtensions -bool true|false"
    ALL_SETTINGS[finder_status_bar]="Finder: show status bar|defaults write com.apple.finder ShowStatusBar -bool true|false"
    ALL_SETTINGS[finder_path_bar]="Finder: show path bar|defaults write com.apple.finder ShowPathbar -bool true|false"
    ALL_SETTINGS[finder_posix_title]="Finder: show full POSIX path in title|defaults write com.apple.finder _FXShowPosixPathInTitle -bool true|false"
    ALL_SETTINGS[finder_folders_first]="Finder: keep folders on top when sorting|defaults write com.apple.finder _FXSortFoldersFirst -bool true|false"
    ALL_SETTINGS[finder_search_current]="Finder: search current folder by default|defaults write com.apple.finder FXDefaultSearchScope -string 'SCcf'|false"
    ALL_SETTINGS[finder_no_ext_warning]="Finder: disable extension change warning|defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false|false"
    ALL_SETTINGS[no_ds_store_network]="Avoid .DS_Store on network volumes|defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true|false"
    ALL_SETTINGS[no_ds_store_usb]="Avoid .DS_Store on USB volumes|defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true|false"
    ALL_SETTINGS[finder_list_view]="Finder: use list view by default|defaults write com.apple.finder FXPreferredViewStyle -string 'Nlsv'|false"
    ALL_SETTINGS[finder_no_trash_warning]="Finder: disable empty trash warning|defaults write com.apple.finder WarnOnEmptyTrash -bool false|false"
    ALL_SETTINGS[airdrop_ethernet]="Enable AirDrop over Ethernet|defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true|false"
    ALL_SETTINGS[show_library]="Show ~/Library folder|chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library 2>/dev/null || true|false"
    ALL_SETTINGS[show_volumes]="Show /Volumes folder|sudo chflags nohidden /Volumes|true"
    ALL_SETTINGS[finder_expand_info]="Finder: expand info panes by default|defaults write com.apple.finder FXInfoPanesExpanded -dict General -bool true OpenWith -bool true Privileges -bool true|false"
    ALL_SETTINGS[finder_no_animations]="Finder: disable window animations|defaults write com.apple.finder DisableAllAnimations -bool true|false"
    ALL_SETTINGS[spring_loading]="Enable spring loading for directories|defaults write NSGlobalDomain com.apple.springing.enabled -bool true && defaults write NSGlobalDomain com.apple.springing.delay -float 0|false"

    # Dock
    ALL_SETTINGS[dock_highlight_stack]="Dock: highlight hover effect on stacks|defaults write com.apple.dock mouse-over-hilite-stack -bool true|false"
    ALL_SETTINGS[dock_minimize_to_app]="Dock: minimize windows to app icon|defaults write com.apple.dock minimize-to-application -bool true|false"
    ALL_SETTINGS[dock_indicators]="Dock: show indicator lights for open apps|defaults write com.apple.dock show-process-indicators -bool true|false"
    ALL_SETTINGS[dock_fast_mission_ctrl]="Dock: speed up Mission Control animations|defaults write com.apple.dock expose-animation-duration -float 0.1|false"
    ALL_SETTINGS[dock_no_autohide_delay]="Dock: remove auto-hide delay|defaults write com.apple.dock autohide-delay -float 0|false"
    ALL_SETTINGS[dock_instant_hide]="Dock: instant hide/show (no animation)|defaults write com.apple.dock autohide-time-modifier -float 0|false"
    ALL_SETTINGS[dock_autohide]="Dock: auto-hide|defaults write com.apple.dock autohide -bool true|false"
    ALL_SETTINGS[dock_no_recents]="Dock: don't show recent apps|defaults write com.apple.dock show-recents -bool false|false"
    ALL_SETTINGS[dock_scale_effect]="Dock: use scale effect for minimize|defaults write com.apple.dock mineffect -string 'scale'|false"
    ALL_SETTINGS[dock_static_only]="Dock: show only open apps|defaults write com.apple.dock static-only -bool true|false"
    ALL_SETTINGS[dock_no_launch_anim]="Dock: don't animate opening apps|defaults write com.apple.dock launchanim -bool false|false"
    ALL_SETTINGS[dock_size_36]="Dock: set icon size to 36px|defaults write com.apple.dock tilesize -int 36|false"

    # Terminal & iTerm2
    ALL_SETTINGS[terminal_utf8]="Terminal: use UTF-8 only|defaults write com.apple.terminal StringEncodings -array 4|false"
    ALL_SETTINGS[iterm_no_quit_prompt]="iTerm2: don't prompt on quit|defaults write com.googlecode.iterm2 PromptOnQuit -bool false|false"

    # Activity Monitor
    ALL_SETTINGS[activity_main_window]="Activity Monitor: show main window on launch|defaults write com.apple.ActivityMonitor OpenMainWindow -bool true|false"
    ALL_SETTINGS[activity_cpu_icon]="Activity Monitor: show CPU in dock icon|defaults write com.apple.ActivityMonitor IconType -int 5|false"
    ALL_SETTINGS[activity_all_processes]="Activity Monitor: show all processes|defaults write com.apple.ActivityMonitor ShowCategory -int 0|false"
    ALL_SETTINGS[activity_sort_cpu]="Activity Monitor: sort by CPU usage|defaults write com.apple.ActivityMonitor SortColumn -string 'CPUUsage' && defaults write com.apple.ActivityMonitor SortDirection -int 0|false"

    # Hot Corners
    ALL_SETTINGS[hotcorner_tl_mission]="Hot corner: top-left → Mission Control|defaults write com.apple.dock wvous-tl-corner -int 2 && defaults write com.apple.dock wvous-tl-modifier -int 0|false"
    ALL_SETTINGS[hotcorner_tr_desktop]="Hot corner: top-right → Desktop|defaults write com.apple.dock wvous-tr-corner -int 4 && defaults write com.apple.dock wvous-tr-modifier -int 0|false"
    ALL_SETTINGS[hotcorner_bl_screensaver]="Hot corner: bottom-left → Screen Saver|defaults write com.apple.dock wvous-bl-corner -int 5 && defaults write com.apple.dock wvous-bl-modifier -int 0|false"
    ALL_SETTINGS[hotcorner_br_lock]="Hot corner: bottom-right → Lock Screen|defaults write com.apple.dock wvous-br-corner -int 13 && defaults write com.apple.dock wvous-br-modifier -int 0|false"

    # Define display order
    SETTINGS_ORDER=(
        # General
        save_to_disk
        quit_printer_app
        disable_app_quarantine
        clean_open_with
        disable_crash_reporter
        login_window_info
        # Input
        trackpad_right_click
        disable_media_keys
        fast_key_repeat
        disable_press_hold
        # Energy
        remove_sleep_image
        # Screenshots
        screenshots_desktop
        screenshots_png
        screenshots_no_shadow
        # Finder
        finder_desktop_default
        finder_show_extensions
        finder_status_bar
        finder_path_bar
        finder_posix_title
        finder_folders_first
        finder_search_current
        finder_no_ext_warning
        no_ds_store_network
        no_ds_store_usb
        finder_list_view
        finder_no_trash_warning
        airdrop_ethernet
        show_library
        show_volumes
        finder_expand_info
        finder_no_animations
        spring_loading
        # Dock
        dock_highlight_stack
        dock_minimize_to_app
        dock_indicators
        dock_fast_mission_ctrl
        dock_no_autohide_delay
        dock_instant_hide
        dock_autohide
        dock_no_recents
        dock_scale_effect
        dock_static_only
        dock_no_launch_anim
        dock_size_36
        # Terminal
        terminal_utf8
        iterm_no_quit_prompt
        # Activity Monitor
        activity_main_window
        activity_cpu_icon
        activity_all_processes
        activity_sort_cpu
        # Hot Corners
        hotcorner_tl_mission
        hotcorner_tr_desktop
        hotcorner_bl_screensaver
        hotcorner_br_lock
    )

    # All OFF by default
    for id in "${SETTINGS_ORDER[@]}"; do
        SETTINGS_ENABLED[$id]=0
    done
}

# Get setting description
get_setting_desc() {
    local id="$1"
    local data="${ALL_SETTINGS[$id]}"
    echo "${data%%|*}"
}

# Get setting command
get_setting_cmd() {
    local id="$1"
    local data="${ALL_SETTINGS[$id]}"
    local rest="${data#*|}"
    echo "${rest%|*}"
}

# Check if setting needs sudo
setting_needs_sudo() {
    local id="$1"
    local data="${ALL_SETTINGS[$id]}"
    [[ "${data##*|}" == "true" ]]
}

# Toggle a setting
toggle_setting() {
    local id="$1"
    if [[ "${SETTINGS_ENABLED[$id]}" == "1" ]]; then
        SETTINGS_ENABLED[$id]=0
    else
        SETTINGS_ENABLED[$id]=1
    fi
}

# Disable a setting
disable_setting() {
    local id="$1"
    SETTINGS_ENABLED[$id]=0
}

# Enable all settings
enable_all_settings() {
    for id in "${SETTINGS_ORDER[@]}"; do
        SETTINGS_ENABLED[$id]=1
    done
}

# Get count of enabled settings
count_enabled_settings() {
    local count=0
    for id in "${SETTINGS_ORDER[@]}"; do
        [[ "${SETTINGS_ENABLED[$id]}" == "1" ]] && count=$((count + 1))
    done
    echo "$count"
}

# Check if any settings need sudo
any_settings_need_sudo() {
    for id in "${SETTINGS_ORDER[@]}"; do
        if [[ "${SETTINGS_ENABLED[$id]}" == "1" ]] && setting_needs_sudo "$id"; then
            return 0
        fi
    done
    return 1
}

# Apply all enabled settings
apply_enabled_settings() {
    local applied=0
    local failed=0

    for id in "${SETTINGS_ORDER[@]}"; do
        if [[ "${SETTINGS_ENABLED[$id]}" == "1" ]]; then
            local desc=$(get_setting_desc "$id")
            local cmd=$(get_setting_cmd "$id")

            echo -n "  Applying: ${desc}... "
            if eval "$cmd" 2>/dev/null; then
                echo "✓"
                applied=$((applied + 1))
            else
                echo "✗"
                failed=$((failed + 1))
            fi
        fi
    done

    echo ""
    echo "Applied: $applied | Failed: $failed"
    return $failed
}

# List all settings with status
list_all_settings() {
    local num=1
    for id in "${SETTINGS_ORDER[@]}"; do
        local desc=$(get_setting_desc "$id")
        local mark="[ ]"
        [[ "${SETTINGS_ENABLED[$id]}" == "1" ]] && mark="[✓]"
        local sudo_marker=""
        setting_needs_sudo "$id" && sudo_marker=" (sudo)"
        printf "%3d. %s %s%s\n" "$num" "$mark" "$desc" "$sudo_marker"
        num=$((num + 1))
    done
}

# Initialize on source
init_settings
