#!/bin/sh
# Cross-platform install functions

# Helper to detect OS and arch for downloads
function _get_os_arch() {
    local os arch
    case "$(uname -s)" in
        Darwin*) os="darwin" ;;
        Linux*)  os="linux" ;;
        MINGW*|MSYS*|CYGWIN*) os="windows" ;;
        *) os="linux" ;;
    esac
    case "$(uname -m)" in
        x86_64|amd64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        armv7l) arch="arm" ;;
        *) arch="amd64" ;;
    esac
    echo "${os}_${arch}"
}

function install-oras(){
    local version="${1:-0.15.0}"
    local os_arch="$(_get_os_arch)"
    local os="${os_arch%%_*}"
    local arch="${os_arch##*_}"
    echo "Installing ORAS: v${version} for ${os}/${arch}"
    curl -LO "https://github.com/oras-project/oras/releases/download/v${version}/oras_${version}_${os}_${arch}.tar.gz"
    mkdir -p oras-install/
    tar -zxf oras_${version}_*.tar.gz -C oras-install/
    sudo mv oras-install/oras /usr/local/bin/
    rm -rf oras_${version}_*.tar.gz oras-install/
    echo "Running: oras version"
    oras version
}

function install-crane(){
    local version="${1:-0.12.1}"
    local os_arch="$(_get_os_arch)"
    # crane uses different naming: Linux/Darwin and x86_64/arm64
    local os=$(echo "${os_arch%%_*}" | sed 's/linux/Linux/; s/darwin/Darwin/')
    local arch=$(echo "${os_arch##*_}" | sed 's/amd64/x86_64/')
    echo "Installing CRANE: v${version} for ${os}/${arch}"
    curl -sL "https://github.com/google/go-containerregistry/releases/download/v${version}/go-containerregistry_${os}_${arch}.tar.gz" > go-containerregistry.tar.gz
    mkdir -p crane-install/
    tar -zxf go-containerregistry.tar.gz -C crane-install/
    sudo mv crane-install/crane /usr/local/bin/
    rm -rf go-containerregistry.tar.gz crane-install/
    echo "Running: crane version"
    crane version
}

function install-syft(){
    local version="${1:-0.62.3}"
    local os_arch="$(_get_os_arch)"
    echo "Installing syft: v${version} for ${os_arch}"
    curl -sL "https://github.com/anchore/syft/releases/download/v${version}/syft_${version}_${os_arch}.tar.gz" > syft.tar.gz
    tar -zxf syft.tar.gz
    sudo mv ./syft /usr/local/bin/syft
    rm -rf syft.tar.gz
    echo "Running: syft version"
    syft version
}

function install-golang(){
    local version="${1:-1.20.5}"
    local os_arch="$(_get_os_arch)"
    local os="${os_arch%%_*}"
    local arch="${os_arch##*_}"
    echo "Installing golang: ${version} for ${os}/${arch}"
    curl -sL "https://go.dev/dl/go${version}.${os}-${arch}.tar.gz" > golang.tar.gz
    rm -rf /usr/local/go && tar -C /usr/local -xzf golang.tar.gz
    rm -rf golang.tar.gz
    echo "Running: go version"
    go version
}

function install-kubectl(){
    local version="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
    if [ "${1}" != "" ]; then
        version="${1}"
    fi
    local os_arch="$(_get_os_arch)"
    local os="${os_arch%%_*}"
    local arch="${os_arch##*_}"
    curl -LO "https://dl.k8s.io/release/${version}/bin/${os}/${arch}/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl 2>/dev/null || \
        install -m 0755 kubectl /usr/local/bin/kubectl
    rm ./kubectl
    kubectl version --client
}