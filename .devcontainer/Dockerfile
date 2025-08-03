FROM mcr.microsoft.com/devcontainers/javascript-node:1-22

RUN npm update -g npm \
  && npm install -g pnpm@latest @google/gemini-cli @anthropic-ai/claude-code \
  && curl -fsSL https://deno.land/install.sh | sh
