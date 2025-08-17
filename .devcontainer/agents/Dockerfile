# syntax=docker/dockerfile:1.4
# check=error=true

# based on:
# https://github.com/anthropics/claude-code/blob/main/.devcontainer/Dockerfile
# https://github.com/google-gemini/gemini-cli/blob/main/Dockerfile

ARG NODE_VERSION=24

FROM --platform=${BUILDPLATFORM} mirror.gcr.io/node:${NODE_VERSION}

ARG TZ=UTC
ENV TZ="$TZ" \
    DEBIAN_FRONTEND=noninteractive \
    DEVCONTAINER=true \
    CLAUDE_DEVCONTAINER=true \
    GEMINI_DEVCONTAINER=true \
    NODE_ENV=development \
    NODE_OPTIONS="--max-old-space-size=4096" \
    NODE_CONFIG_PREFIX="/home/node/.npm-global" \
    TERM=xterm-256color \
    COLORTERM=truecolor

# Install basic tools and dependencies
RUN \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update \
    && apt-get -y install --no-install-recommends \
    aggregate \
    bc \
    build-essential \
    ca-certificates \
    curl \
    dnsutils \
    fonts-font-awesome \
    fonts-noto-cjk \
    fonts-powerline \
    fzf \
    g++ \
    gh \
    git \
    gnupg \
    htop \
    iproute2 \
    ipset \
    iptables \
    jq \
    less \
    locales \
    lsb-release \
    lsof \
    make \
    man-db \
    net-tools \
    procps \
    psmisc \
    python3 \
    python3-pip \
    ripgrep \
    rsync \
    socat \
    sudo \
    tmux \
    unzip \
    vim \
    wget \
    zsh

# Install git delta
# https://github.com/dandavison/delta
ARG GIT_DELTA_VERSION=0.18.2
RUN ARCH=$(dpkg --print-architecture) \
    && wget "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" \
    && dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" \
    && rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb"

# Generate locale
ARG LANGUAGE="en"
ARG COUNTRY="US"
ARG ENCODING="UTF-8"
ARG LOCALE="en_US.UTF-8 UTF-8"
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "${LOCALE}" >> /etc/locale.gen \
    && cat /etc/locale.gen | uniq > /etc/locale.gen \
    && locale-gen \
    && locale -a
ENV LANG="${LANGUAGE}_${COUNTRY}.${ENCODING}"
ENV LANGUAGE="${LANGUAGE}_${COUNTRY}"
ENV LC_ALL="${LANG}"

# Copy files
COPY init-firewall.sh entrypoint.sh /usr/local/bin/

# Ensure default node user has access to /usr/local/share
RUN mkdir -p /usr/local/share/npm-global \
    && chown -R node:node /usr/local/share \
    && mkdir -p /home/node/.config /home/node/.local /home/node/.claude /home/node/.gemini \
    && chown -R node:node /home/node/ \
    # Add node user to sudoers for firewall script
    && echo "node ALL=(ALL) NOPASSWD: /usr/local/bin/init-firewall.sh" >> /etc/sudoers.d/node \
    && chmod 0440 /etc/sudoers.d/node \
    # command history
    && mkdir -p /commandhistory \
    && touch /commandhistory/.bash_history \
    && touch /commandhistory/.zsh_history \
    && chown -R node:node /commandhistory \
    && mkdir -p /workspace \
    && chown -R node:node /workspace \
    && chmod +x /usr/local/bin/*.sh



# Switch to runtime node user
USER node
WORKDIR /workspace

ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global \
    PATH=$PATH:/usr/local/share/npm-global/bin \
    SHELL=/bin/zsh \
    EDITOR=vim \
    VISUAL=vim

RUN npm install -g \
    npm@latest \
    @google/gemini-cli@latest \
    @anthropic-ai/claude-code@latest \
    @openai/codex@latest \
    typescript@latest \
    tsx@latest \
    nodemon@latest \
    npm-check-updates@latest \
    && npm cache clean --force

# Default powerline10k theme
ARG ZSH_IN_DOCKER_VERSION=1.2.1
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v${ZSH_IN_DOCKER_VERSION}/zsh-in-docker.sh)" -- \
    -p git \
    -p fzf \
    -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
    -a "source /usr/share/doc/fzf/examples/completion.zsh" \
    -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    -x

# Set up command history
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && echo "$SNIPPET" >> "/home/node/.bashrc" \
    && echo "$SNIPPET" >> "/home/node/.zshrc"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
