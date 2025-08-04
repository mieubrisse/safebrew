FROM node:20

ARG TZ
ENV TZ="$TZ"

ARG CLAUDE_CODE_VERSION=latest
ARG GIT_DELTA_VERSION=0.18.2
ARG ZSH_IN_DOCKER_VERSION=1.2.0
ARG GO_VERSION=1.23

# Install basic development tools and iptables/ipset
RUN apt-get update && apt-get install -y --no-install-recommends \
    less \
    git \
    procps \
    sudo \
    fzf \
    zsh \
    man-db \
    unzip \
    gnupg2 \
    gh \
    iptables \
    ipset \
    iproute2 \
    dnsutils \
    aggregate \
    jq \
    nano \
    vim \
    curl \
    wget \
    build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Go via apt-get
RUN apt-get update && apt-get install -y --no-install-recommends \
    golang-go \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV GOPATH="/home/node/go"
ENV GOBIN="/home/node/go/bin"
ENV PATH="${GOBIN}:${PATH}"

# Create directories for persistent volumes
RUN mkdir -p /commandhistory /home/node/.claude

# Set up bash history persistence
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && mkdir -p /commandhistory \
    && touch /commandhistory/.bash_history \
    && chown -R node:node /commandhistory \
    && echo "$SNIPPET" >> "/home/node/.bashrc"

# Install Git Delta for better git diffs
RUN wget -q "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_arm64.deb" \
    && dpkg -i "git-delta_${GIT_DELTA_VERSION}_arm64.deb" \
    && rm "git-delta_${GIT_DELTA_VERSION}_arm64.deb"

# Install zsh-in-docker for better shell experience
RUN wget -q "https://github.com/deluan/zsh-in-docker/releases/download/v${ZSH_IN_DOCKER_VERSION}/zsh-in-docker.sh" \
    && chmod +x zsh-in-docker.sh \
    && ./zsh-in-docker.sh \
        -t robbyrussell \
        -p git \
        -p ssh-agent \
        -p https://github.com/agkozak/zsh-z \
        -p https://github.com/zsh-users/zsh-autosuggestions \
        -p https://github.com/zsh-users/zsh-syntax-highlighting \
    && rm zsh-in-docker.sh

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# Give node user sudo access for firewall management
RUN usermod -aG sudo node && echo "node ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/node

# Set up Go workspace for node user
RUN mkdir -p /home/node/go/{bin,src,pkg} && chown -R node:node /home/node/go

# Switch to node user
USER node

# Set working directory
WORKDIR /workspace

# Configure Git Delta as the default pager
RUN git config --global core.pager delta \
    && git config --global interactive.diffFilter "delta --color-only" \
    && git config --global delta.navigate true \
    && git config --global merge.conflictstyle diff3 \
    && git config --global diff.colorMoved default

# Set up zsh as default shell for node user
RUN sudo chsh -s /bin/zsh node
