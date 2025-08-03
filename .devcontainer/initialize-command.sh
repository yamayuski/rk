#!/usr/bin/env bash

# Initialize in host environment(WSL, macOS, Linux) before starting the container

set -euo pipefail

_is_root() {
    [ $(id -u) -eq 0 ]
}

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

    if [ -d /opt/rk ] && [ -f /opt/rk/cert.pem ] && [ -f /opt/rk/key.pem ]; then
        echo "mkcert is already installed and configured."
        return 0
    fi

    if _is_root; then
        echo "Running as root"
        mkdir -p /opt/rk
    else
        echo "Running as $(whoami)"
        sudo mkdir -p /opt/rk
        sudo chown -R "$(whoami):$(whoami)" /opt/rk
    fi

    if grep -qi WSL2 /proc/version; then
        echo "Running in WSL2 environment"
        set +e
        WINGET_EXE_PATH=$(echo "/mnt/c/Users/$(cmd.exe /c echo %USERNAME% | tr -d '\r')/AppData/Local/Microsoft/WindowsApps/winget.exe")
        if [ ! -f "$WINGET_EXE_PATH" ]; then
            echo "winget is not installed. Please install winget first."
            exit 1
        fi
        ${WINGET_EXE_PATH} install --id=FiloSottile.mkcert -e
        WINGET_EXIT_CODE=$?
        set -e
        if [ $WINGET_EXIT_CODE -eq 43 ]; then
            echo "winget is already installed"
        elif [ $WINGET_EXIT_CODE -ne 0 ]; then
            echo "winget installation failed"
            exit 1
        fi
        mkcert.exe -install
        mkcert.exe -key-file=/opt/rk/key.pem -cert-file=/opt/rk/cert.pem rk.localhost "*.rk.localhost"
        cp "$(wslpath $(mkcert.exe -CAROOT))/rootCA.pem" /opt/rk/rootCA.pem
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        echo "Running in macOS environment"
        brew install mkcert nss
        mkcert -install
        mkcert -key-file=/opt/rk/key.pem -cert-file=/opt/rk/cert.pem rk.localhost "*.rk.localhost"
        cp "$(mkcert -CAROOT)/rootCA.pem" /opt/rk/rootCA.pem
    elif [[ "$(uname -s)" == "Linux" ]]; then
        echo "Running in Linux environment"
        MKCERT_VERSION="v1.4.4"
        if _is_root; then
            apt update && apt install -y libnss3-tools curl tar
            curl -sL "https://github.com/FiloSottile/mkcert/releases/download/${MKCERT_VERSION}/mkcert-${MKCERT_VERSION}-linux-$(_get_arch).tar.gz" | tar xzf - -C /usr/local/bin
            chmod +x /usr/local/bin/mkcert
        else
            sudo apt update && sudo apt install -y libnss3-tools curl tar
            curl -sL "https://github.com/FiloSottile/mkcert/releases/download/${MKCERT_VERSION}/mkcert-${MKCERT_VERSION}-linux-$(_get_arch).tar.gz" | sudo tar xzf - -C /usr/local/bin
            sudo chmod +x /usr/local/bin/mkcert
        fi
        mkcert -install
        mkcert -key-file=/opt/rk/key.pem -cert-file=/opt/rk/cert.pem rk.localhost "*.rk.localhost"
        cp "$(mkcert -CAROOT)/rootCA.pem" /opt/rk/rootCA.pem
    else
        echo "Unsupported operating system: $(uname -s)"
        exit 1
    fi
}

_install_mkcert

export RK_UID=$(id -u)
export RK_GID=$(id -g)
