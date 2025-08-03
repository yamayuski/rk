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

_find_exe_in_windows() {
  local -r exe_name=$1
  local -r subdir=$2

  if [ -z "$exe_name" ]; then
    echo "Usage: _find_exe_in_windows <exe_name> <subdir>"
    return 1
  fi

  which_exe_path=$(which "$exe_name" 2> /dev/null)
  if [ -x "$which_exe_path" ]; then
    echo "$which_exe_path"
    return 0
  fi

  for drv in /mnt/*; do
    if [ -d "$drv/$subdir" ]; then
      found_path=$(find "$drv/$subdir" -type f -name "$exe_name" 2> /dev/null | head -n 1)
      if [ -x "$found_path" ]; then
        echo "$found_path"
        return 0
      fi
    fi
  done
  return 2
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
        WINGET_EXE_PATH=$(_find_exe_in_windows "winget.exe" "Users")
        if [ -z "$WINGET_EXE_PATH" ]; then
            echo "winget.exe not found. Please install winget and ensure it is in your PATH or a common location."
            exit 1
        fi
        set +e
        ${WINGET_EXE_PATH} install --id=FiloSottile.mkcert -e
        WINGET_EXIT_CODE=$?
        set -e
        if [ $WINGET_EXIT_CODE -eq 43 ]; then
            echo "winget is already installed"
        elif [ $WINGET_EXIT_CODE -ne 0 ]; then
            echo "winget installation failed"
            exit 1
        fi
        MKCERT_EXE_PATH=$(_find_exe_in_windows "mkcert.exe" "Users")
        if [ -z "$MKCERT_EXE_PATH" ]; then
            echo "mkcert.exe not found. Please install mkcert and ensure it is in your PATH or a common location."
            exit 1
        fi
        ${MKCERT_EXE_PATH} -install
        ${MKCERT_EXE_PATH} -key-file=/opt/rk/key.pem -cert-file=/opt/rk/cert.pem rk.localhost "*.rk.localhost"
        cp "$(wslpath $(${MKCERT_EXE_PATH} -CAROOT))/rootCA.pem" /opt/rk/rootCA.pem
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
