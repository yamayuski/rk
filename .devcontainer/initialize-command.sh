#!/usr/bin/env bash

# Initialize in host environment(WSL, macOS, Linux) before starting the container

set -euo pipefail

_get_arch() {
    case "$(uname -m)" in
        x86_64|amd64) echo "amd64" ;;
        aarch64) echo "arm64" ;;
        armv7l) echo "arm" ;;
        *) echo "unknown" ;;
    esac
}

_install_mkcert() {
    set -euo pipefail

    mkdir -p ~/.local/rk

    if grep -qi WSL2 /proc/version; then
        echo "Running in WSL2 environment"
        set +e
        winget.exe install --id=FiloSottile.mkcert -e
        WINGET_EXIT_CODE=$?
        set -e
        if [ $WINGET_EXIT_CODE -eq 43 ]; then
            echo "winget is already installed"
        elif [ $WINGET_EXIT_CODE -ne 0 ]; then
            echo "winget installation failed"
            exit 1
        fi
        mkcert.exe -install
        mkcert.exe -key-file=~/.local/rk/key.pem -cert-file=~/.local/rk/cert.pem rk.localhost "*.rk.localhost"
        cp "$(mkcert.exe -CAROOT)/rootCA.pem" ~/.local/rk/rootCA.pem
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        echo "Running in macOS environment"
        brew install mkcert nss
        mkcert -install
        mkcert -key-file=~/.local/rk/key.pem -cert-file=~/.local/rk/cert.pem rk.localhost "*.rk.localhost"
        cp "$(mkcert -CAROOT)/rootCA.pem" ~/.local/rk/rootCA.pem
    elif [[ "$(uname -s)" == "Linux" ]]; then
        echo "Running in Linux environment"
        sudo apt-get install -y libnss3-tools
        MKCERT_VERSION="v1.4.4"
        curl -sL "https://github.com/FiloSottile/mkcert/releases/download/${MKCERT_VERSION}/mkcert-${MKCERT_VERSION}-linux-${_get_arch}.tar.gz" | sudo tar xz -C /usr/local/bin mkcert
        sudo chmod +x /usr/local/bin/mkcert
        mkcert -install
        mkcert -key-file=~/.local/rk/key.pem -cert-file=~/.local/rk/cert.pem rk.localhost "*.rk.localhost"
        cp "$(mkcert -CAROOT)/rootCA.pem" ~/.local/rk/rootCA.pem
    else
        echo "Unsupported operating system: $(uname -s)"
        exit 1
    fi
}
