FROM mcr.microsoft.com/devcontainers/base:bookworm

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install \
    git \
    python3-pip \
    pipx \
    ansible-lint \
    pwgen \ 
    && pipx install --include-deps ansible \
    && wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
    && apt update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install \
    terraform \
    awscli \
    && rm -rf /var/lib/apt/lists/* \
    && cd /root \
    && wget https://github.com/StackExchange/blackbox/archive/refs/tags/stable.zip -O blackbox.zip \
    && unzip blackbox.zip \
    && cd blackbox-stable \
    && make copy-install \
    && cd .. \
    && rm -rf blackbox.zip blackbox-stable
