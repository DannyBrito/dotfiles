#!/bin/sh
# macOS essential settings - lightweight defaults for bootstrap
# For comprehensive settings, see macos/prefs/settings.sh

# Apply essential macOS settings
# Usage: setup_macos_essentials [mode]
#   mode: "auto" = apply without prompting
#         "skip" = skip without prompting
#         ""     = interactive prompt (default)
setup_macos_essentials() {
    local mode="${1:-}"

    log ""
    log "🍎 macOS Essential Settings"
    log "   This will configure: Dock, Finder, Trackpad, Menu Bar"
    log ""

    # Handle mode or prompt
    case "$mode" in
        auto)
            log "   Applying settings (--macos flag)..."
            ;;
        skip)
            log "   Skipping macOS settings (--no-macos flag)."
            return 0
            ;;
        *)
            # Interactive prompt
            printf "   Apply macOS essential settings? [y/N] "
            read -r response
            case "$response" in
                [yY][eE][sS]|[yY])
                    log ""
                    log "   Applying settings..."
                    ;;
                *)
                    log "   Skipping macOS settings."
                    return 0
                    ;;
            esac
            ;;
    esac

    # Dock settings
    log "   • Dock: auto-hide, fast animation, magnification"
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock autohide-time-modifier -float 0.05
    defaults write com.apple.dock autohide-delay -float 0
    defaults write com.apple.dock magnification -bool true
    defaults write com.apple.dock largesize -int 128
    defaults write com.apple.dock tilesize -int 70
    defaults write com.apple.dock minimize-to-application -bool true
    defaults write com.apple.dock show-process-indicators -bool true
    defaults write com.apple.dock show-recents -bool false

    # Trackpad: right-click via bottom-right corner
    log "   • Trackpad: right-click via bottom-right corner"
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

    # Disable media keys hijacking Music.app
    log "   • Input: disable media keys for Music.app"
    launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2>/dev/null || true

    # Finder settings
    log "   • Finder: path bar, folders first, search current, show ~/Library"
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder _FXSortFoldersFirst -bool true
    defaults write com.apple.finder FXDefaultSearchScope -string 'SCcf'
    chflags nohidden ~/Library
    xattr -d com.apple.FinderInfo ~/Library 2>/dev/null || true
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    # Menu bar: show seconds in clock
    log "   • Menu Bar: show seconds in clock"
    defaults write com.apple.menuextra.clock ShowSeconds -bool true

    # Restart Dock and Finder to apply changes
    log "   • Restarting Dock and Finder..."
    killall Dock 2>/dev/null || true
    killall Finder 2>/dev/null || true

    log "   ✓ macOS settings applied!"
}
