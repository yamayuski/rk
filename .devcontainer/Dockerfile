# syntax=docker/dockerfile:1.4
# check=error=true

ARG NODE_VERSION=24

FROM --platform=${BUILDPLATFORM} mirror.gcr.io/node:${NODE_VERSION}

ARG USERNAME=node
ARG USER_UID=1000
ARG USER_GID=1000
ARG TZ=UTC
ARG LANGUAGE=en
ARG COUNTRY=US
ARG ENCODING=UTF-8
ARG LOCALE="en_US.UTF-8 UTF-8"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ="$TZ"


# Install basic tools and dependencies
RUN \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update \
    && apt-get -y install --no-install-recommends \
    aggregate \
    ca-certificates \
    curl \
    dnsutils \
    fonts-font-awesome \
    fonts-noto-cjk \
    fonts-powerline \
    fzf \
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

RUN \
    (getent group $USER_GID && groupmod --gid $USER_GID $USERNAME || groupadd -g $USER_GID $USERNAME) && \
    (getent passwd $USER_UID && usermod --uid $USER_UID --gid $USER_GID -s /bin/bash -m -d /home/$USERNAME $USERNAME || useradd -u $USER_UID -g $USER_GID -s /bin/bash -m $USERNAME) && \
    echo "${USERNAME} ALL=\(root\) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}" && \
    chmod 0440 "/etc/sudoers.d/${USERNAME}" && \
    mkdir -p /workspace && \
    chown -R ${USER_UID}:${USER_GID} "/home/${USERNAME}" /workspace

# https://code.visualstudio.com/remote/advancedcontainers/persist-bash-history
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && mkdir /commandhistory \
    && touch /commandhistory/.bash_history \
    && chown -R ${USER_UID}:${USER_GID} /commandhistory \
    && echo "$SNIPPET" >> "/home/${USERNAME}/.bashrc"
