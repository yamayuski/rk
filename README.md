# rk

rk - Arche Original-chain

## Goal

A project aimed at protecting original creators' rights and improving content reliability by applying digital signatures to Human-generated Content (text, images, audio, video, 3D models, software, etc.) worldwide and expressing the relationship between originals and copies. It also distinguishes from AI-generated Content and enforces learning restrictions.

A self-contained signature specification that does not depend on infrastructure held by specific companies or organizations. Provides lightweight implementation that can sign and verify with just a browser / CLI.

## Installation

Using DevContainers with [vscode](https://code.visualstudio.com/) and
[vscode Remote extension](vscode:extension/ms-vscode-remote.vscode-remote-extensionpack)

[![Open this repository in Dev Containers](https://img.shields.io/static/v1?label=Dev%20Containers&message=Open&color=blue)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/yamayuski/rk)

### NOTICE: in Windows and WSL2

You must add to this in settings.json before opening devcontainer.

```json
{
  "dev.containers.executeInWSL": true
}
```

### Optional: clone manually

- Docker Desktop or Docker Engine

```sh
git clone https://github.com/yamayuski/rk.git
cd rk
```

And `reopen in container`
