#!/usr/bin/env zsh
# Core library functions for macOS preferences management
# Provides version detection, logging, and common utilities

# Guard against multiple sourcing
[[ -n "${_MACOS_PREFS_CORE_LOADED:-}" ]] && return 0
_MACOS_PREFS_CORE_LOADED=1

set -euo pipefail

# Colors for output
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
NC=$'\033[0m' # No Color
BOLD=$'\033[1m'
REVERSE=$'\033[7m'

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_section() {
    echo -e "\n${BOLD}${CYAN}==> $*${NC}"
}

# Get macOS version information
get_macos_version() {
    sw_vers -productVersion
}

get_macos_major_version() {
    sw_vers -productVersion | cut -d. -f1
}

get_macos_name() {
    local major=$(get_macos_major_version)

    case "$major" in
        15) echo "Sequoia" ;;
        14) echo "Sonoma" ;;
        13) echo "Ventura" ;;
        12) echo "Monterey" ;;
        11) echo "Big Sur" ;;
        10)
            local minor=$(sw_vers -productVersion | cut -d. -f2)
            case "$minor" in
                15) echo "Catalina" ;;
                14) echo "Mojave" ;;
                13) echo "High Sierra" ;;
                12) echo "Sierra" ;;
                *)  echo "macOS 10.$minor" ;;
            esac
            ;;
        *) echo "macOS $major" ;;
    esac
}

# Check if SIP is enabled
is_sip_enabled() {
    csrutil status 2>/dev/null | grep -q "enabled"
}

# Quit an application gracefully
quit_app() {
    local app="$1"
    if pgrep -xq "$app"; then
        osascript -e "tell application \"$app\" to quit" 2>/dev/null || true
        sleep 1
    fi
}

# Kill affected system applications (use carefully)
kill_system_apps() {
    local apps=("$@")
    for app in "${apps[@]}"; do
        killall "$app" 2>/dev/null || true
    done
}
