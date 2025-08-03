#!/usr/bin/env bash

set -euo pipefail

npm update -g npm \
  && npm install -g @google/gemini-cli @anthropic-ai/claude-code \
  && curl -fsSL https://deno.land/install.sh | sh

sudo chown -R rk:rk /workspace /opt/rk

if [ ${#} -gt 0 ]; then
  exec "${@}"
fi
