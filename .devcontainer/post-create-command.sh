#!/usr/bin/env bash

set -euo pipefail

# rk group can modify /usr/local
sudo chown -R root:rk /usr/local
find /usr/local -type d -exec sudo chmod g+wx {} +
find /usr/local -type f -perm 644 -exec sudo chmod 664 {} +
find /usr/local -type f -perm 744 -exec sudo chmod 774 {} +

npm update -g npm \
  && npm install -g @google/gemini-cli @anthropic-ai/claude-code \
  && curl -fsSL https://deno.land/install.sh | sh --yes

sudo chown -R rk:rk /workspaces /opt/rk

if [ ${#} -gt 0 ]; then
  exec "${@}"
fi
