# This is the latest Version of Python
FROM python:3.12-trixie

ARG USERNAME=ansible
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Filesystem encoding and non-interactive apt
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

# System packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-utils \
        ca-certificates \
        curl \
        git \
        gnupg \
        jq \
        lsb-release \
        sudo \
    && curl -sLS https://packages.microsoft.com/keys/microsoft.asc \
        | gpg --dearmor \
        | tee /etc/apt/keyrings/microsoft.gpg > /dev/null \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) stable" \
        | tee /etc/apt/sources.list.d/azure-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        azure-cli \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip3 install --upgrade \
    setuptools \
    pip

# Install dependencies
ADD requirements.txt /requirements.txt
RUN pip3 install --upgrade -r /requirements.txt

# Install Azure Anisble and its requirements
RUN ansible-galaxy collection install azure.azcollection --force && \
    pip install -r $(find / -name "requirements.txt" -path "*/azure/azcollection/*" 2>/dev/null | head -1)

RUN ln -s /usr/bin/python3 /usr/bin/python \
    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support for the non-root user
    && apt-get install sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    #
    # Clean up
    && apt-get autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER $USERNAME