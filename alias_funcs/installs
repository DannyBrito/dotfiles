#!/bin/sh

function install-oras(){
    local version="${1:-0.15.0}"
    echo "Installing ORAS: v${version}"
    curl -LO https://github.com/oras-project/oras/releases/download/v${version}/oras_${version}_linux_amd64.tar.gz
    mkdir -p oras-install/
    tar -zxf oras_${version}_*.tar.gz -C oras-install/
    sudo mv oras-install/oras /usr/local/bin/
    rm -rf oras_${version}_*.tar.gz oras-install/
    echo "Running: oras version"
    oras version
}

function install-crane(){
    local version="${1:-0.12.1}"
    echo "Installing CRANE: v${version}"
    curl -sL "https://github.com/google/go-containerregistry/releases/download/v${version}/go-containerregistry_Linux_x86_64.tar.gz" > go-containerregistry.tar.gz
    mkdir -p crane-install/
    tar -zxf go-containerregistry.tar.gz -C crane-install/
    sudo mv crane-install/crane /usr/local/bin/
    rm -rf go-containerregistry.tar.gz crane-install/
    echo "Running: crane version"
    crane version
}

function install-syft(){
    local version="${1:-0.62.3}"
    echo "Installing syft: v${version}"
    curl -sL "https://github.com/anchore/syft/releases/download/v${version}/syft_${version}_linux_amd64.tar.gz" > syft.tar.gz
    tar -zxf syft.tar.gz
    sudo mv ./syft /usr/local/bin/syft
    rm -rf syft.tar.gz
    echo "Running: syft version"
    syft version
}

function install-golang(){
    local version="${1:-1.20.5}"
    echo "Installing golang: ${version}"
    curl -sL "https://go.dev/dl/go${version}.linux-amd64.tar.gz" > golang.tar.gz
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
    curl -LO "https://dl.k8s.io/release/${version}/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm ./kubectl
    kubectl version --short
}