FROM mirror.gcr.io/node:22-bookworm

ARG TZ
ENV TZ="$TZ"

ARG GEMINI_CODE_VERSION=latest

ENV DEBIAN_FRONTEND=noninteractive

# Install basic tools and dependencies
RUN apt-get update \
    && apt-get -y install --no-install-recommends \
        aggregate \
        build-essential \
        ca-certificates \
        curl \
        dnsutils \
        dnsutils \
        fonts-powerline \
        fzf \
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
        man-db \
        net-tools \
        procps \
        python3 \
        python3-pip \
        sudo \
        tmux \
        unzip \
        vim \
        wget \
        zsh \
    && apt-get autoremove -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

ARG GIT_DELTA_VERSION=0.18.2
RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb"

# Generate locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Ensure default node user has access to /usr/local/share
RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share

# Add node user to sudoers for firewall script
RUN echo "node ALL=(ALL) NOPASSWD: /workspace/.devcontainer/gemini/init-firewall.sh" >> /etc/sudoers.d/node \
    && chmod 0440 /etc/sudoers.d/node

# Create npm global directory
RUN mkdir -p /home/node/.npm-global \
    && chown -R node:node /home/node/.npm-global

# Install global npm packages as node user
USER node

# Install global packages
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin
ENV DEVCONTAINER=true

# Set the default shell to zsh rather than sh
ENV SHELL=/bin/zsh

# Set the default editor and visual
ENV EDITOR nano
ENV VISUAL nano

RUN npm install -g \
    @google/gemini-cli \
    typescript \
    tsx \
    nodemon \
    npm-check-updates \
    && npm cache clean --force

# Switch back to root for final setup
USER root

# Set up command history
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && mkdir -p /commandhistory \
    && chown -R node:node /commandhistory \
    && touch /commandhistory/.bash_history \
    && echo "$SNIPPET" >> "/home/node/.bashrc" \
    && echo "$SNIPPET" >> "/home/node/.zshrc"

# Create workspace directory
RUN mkdir -p /workspace && chown -R node:node /workspace

# Copy firewall initialization script
COPY init-firewall.sh /workspace/.devcontainer/gemini/init-firewall.sh
RUN chmod +x /workspace/.devcontainer/gemini/init-firewall.sh

# Set up entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER node
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
