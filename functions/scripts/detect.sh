#!/bin/sh
# Shell and environment detection utilities
# This file uses POSIX sh for maximum compatibility

# Detect the current running shell
detect_shell() {
    # Check the current process name
    local shell_name
    if [ -n "$ZSH_VERSION" ]; then
        shell_name="zsh"
    elif [ -n "$BASH_VERSION" ]; then
        shell_name="bash"
    elif [ -n "$FISH_VERSION" ]; then
        shell_name="fish"
    else
        # Fallback to parsing $0 or $SHELL
        shell_name="$(basename "${SHELL:-sh}")"
    fi
    echo "$shell_name"
}

# Check if current shell is zsh
is_zsh() {
    [ -n "$ZSH_VERSION" ]
}

# Check if current shell is bash
is_bash() {
    [ -n "$BASH_VERSION" ]
}

# Detect OS type
detect_os() {
    case "$(uname -s)" in
        Darwin*)  echo "macos" ;;
        Linux*)   echo "linux" ;;
        CYGWIN*)  echo "windows" ;;
        MINGW*)   echo "windows" ;;
        MSYS*)    echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}

# Detect architecture (for downloads)
detect_arch() {
    local arch
    arch="$(uname -m)"
    case "$arch" in
        x86_64|amd64)   echo "amd64" ;;
        aarch64|arm64)  echo "arm64" ;;
        armv7l)         echo "arm" ;;
        *)              echo "$arch" ;;
    esac
}

# Detect environment type
detect_environment() {
    if [ -n "${CODESPACES:-}" ]; then
        echo "codespaces"
    elif [ -n "${GITPOD_WORKSPACE_ID:-}" ]; then
        echo "gitpod"
    elif [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
        echo "docker"
    elif [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
    elif [ -n "${SSH_CONNECTION:-}" ]; then
        echo "ssh"
    elif [ "$(detect_os)" = "macos" ]; then
        echo "macos"
    else
        echo "local"
    fi
}

# Check if running in a container
is_container() {
    [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null || [ -n "${CODESPACES:-}" ]
}

# Check if running on a headless system (no GUI)
is_headless() {
    [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ] && [ "$(detect_os)" != "macos" ]
}

# Check if we have sudo access (without prompting)
has_sudo() {
    sudo -n true 2>/dev/null
}

# Check if interactive shell
is_interactive() {
    case "$-" in
        *i*) return 0 ;;
        *)   return 1 ;;
    esac
}

# Get the correct fzf shell extension path
get_fzf_shell_path() {
    local shell_type="$1"
    local fzf_base="${HOME}/.fzf/shell"

    if [ ! -d "$fzf_base" ]; then
        # Try system-wide installation
        if [ -d "/usr/share/fzf" ]; then
            fzf_base="/usr/share/fzf"
        elif [ -d "/opt/homebrew/opt/fzf/shell" ]; then
            fzf_base="/opt/homebrew/opt/fzf/shell"
        elif [ -d "/usr/local/opt/fzf/shell" ]; then
            fzf_base="/usr/local/opt/fzf/shell"
        fi
    fi

    echo "$fzf_base"
}

# Source fzf for the current shell
setup_fzf() {
    local shell_type
    shell_type="$(detect_shell)"
    local fzf_base
    fzf_base="$(get_fzf_shell_path "$shell_type")"

    if [ ! -d "$fzf_base" ]; then
        return 1
    fi

    case "$shell_type" in
        zsh)
            [ -f "$fzf_base/completion.zsh" ] && . "$fzf_base/completion.zsh"
            [ -f "$fzf_base/key-bindings.zsh" ] && . "$fzf_base/key-bindings.zsh"
            ;;
        bash)
            [ -f "$fzf_base/completion.bash" ] && . "$fzf_base/completion.bash"
            [ -f "$fzf_base/key-bindings.bash" ] && . "$fzf_base/key-bindings.bash"
            ;;
        fish)
            # Fish handles this differently via conf.d
            ;;
    esac
}

# Print all detection info (useful for debugging)
print_env_info() {
    echo "Shell: $(detect_shell)"
    echo "OS: $(detect_os)"
    echo "Arch: $(detect_arch)"
    echo "Environment: $(detect_environment)"
    echo "Interactive: $(is_interactive && echo yes || echo no)"
    echo "Container: $(is_container && echo yes || echo no)"
    echo "Headless: $(is_headless && echo yes || echo no)"
}
