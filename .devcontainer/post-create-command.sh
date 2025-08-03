#!/usr/bin/env bash

set -euo pipefail

sudo npm install -g @google/gemini-cli@latest @anthropic-ai/claude-code@latest npm@latest

sudo chown -R rk:rk /workspaces
