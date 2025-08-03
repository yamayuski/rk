# rk

rk - Arche Original-chain

## Installation

[![Open this repository in Dev Containers](https://img.shields.io/static/v1?label=Dev%20Containers&message=Open&color=blue)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/yamayuski/rk)

### Optional: clone manually

- Docker Desktop or Docker Engine
- docker compose v2

```sh
$ git clone https://github.com/yamayuski/rk.git
$ cd rk
# automatically installs mkcert
$ ./.devcontainer/initialize-command.sh
$ docker compose up -d
$ docker compose exec rk bash
```
