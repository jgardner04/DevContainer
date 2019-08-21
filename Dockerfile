FROM ubuntu:latest

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# This Dockerfile adds a non-root 'vscode' user with sudo access. However, for Linux,
# this user's GID/UID must match your local user UID/GID to avoid permission issues
# with bind mounts. Update USER_UID / USER_GID if yours is not 1000. See
# https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Terraform and tflint versions
ARG TERRAFORM_VERSION=0.12.6
ARG TFLINT_VERSION=0.9.3
ARG PACKER_VERSION=1.4.3

# Install Basic Packages
RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get -y install apt-utils \
  && apt-get -y install \
  ca-certificates \
  curl \
  apt-transport-https \
  lsb-release \
  gnupg \
  wget \
  gpg \
  git \
  zsh \
  tmux \
  jq \
  vim \
  unzip \
  zip \
  build-essential \
  #
  # Install Kubectl
  && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
  && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list \
  && apt-get update \
  && apt-get install -y kubectl \
  #
  # Install Azure CLI
  && curl -sL https://aka.ms/InstallAzureCLIDeb | bash \
  #
  #
  # Install Terraform, tflint, and graphviz
  && mkdir -p /tmp/docker-downloads \
  && curl -sSL -o /tmp/docker-downloads/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && unzip /tmp/docker-downloads/terraform.zip \
  && mv terraform /usr/local/bin \
  && curl -sSL -o /tmp/docker-downloads/tflint.zip https://github.com/wata727/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip \
  && unzip /tmp/docker-downloads/tflint.zip \
  && mv tflint /usr/local/bin \
  && cd ~ \
  && rm -rf /tmp/docker-downloads \
  && apt-get install -y graphviz \
  #
  # Install Packer
  && mkdir -p /tmp/hashicorp-downloads \
  && curl -sSL -o /tmp/hashicorp-downloads/packer.zip https://releases.hashicorp.com/packer/1.4.3/packer_${PACKER_VERSION}_linux_amd64.zip \
  && unzip /tmp/hashicorp-downloads/packer.zip \
  && mv packer /usr/local/bin \
  # Install .NET
  && wget -q https://packages.microsoft.com/config/ubuntu/19.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
  && dpkg -i packages-microsoft-prod.deb \
  && apt-get update \
  && apt-get install dotnet-sdk-2.2 -y \
  #
  # Install NodeJS
  && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
  && apt-get -y install nodejs \
  #
  # Install Go
  && wget -q https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz -O go1.12.7.linux-amd64.tar.gz \
  && tar -C /usr/local -xzf go1.12.7.linux-amd64.tar.gz \
  && echo 'PATH=$PATH:/usr/local/go/bin' \
  # Install Go tools
  && /usr/local/go/bin/go get -u -v \
  github.com/uudashr/gopkgs/cmd/gopkgs \
  github.com/ramya-rao-a/go-outline \
  github.com/acroca/go-symbols \
  github.com/godoctor/godoctor \
  golang.org/x/tools/cmd/guru \
  golang.org/x/tools/cmd/gorename \
  github.com/rogpeppe/godef \
  github.com/zmb3/gogetdoc \
  github.com/haya14busa/goplay/cmd/goplay \
  github.com/sqs/goreturns \
  github.com/josharian/impl \
  github.com/davidrjenni/reftools/cmd/fillstruct \
  github.com/fatih/gomodifytags \
  github.com/cweill/gotests/... \
  golang.org/x/tools/cmd/goimports \
  golang.org/x/lint/golint \
  golang.org/x/tools/cmd/gopls \
  github.com/alecthomas/gometalinter \
  honnef.co/go/tools/... \
  github.com/golangci/golangci-lint/cmd/golangci-lint \
  github.com/mgechev/revive \
  github.com/derekparker/delve/cmd/dlv 2>&1  \
  #
  # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
  && groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  # [Optional] Add sudo support
  && apt-get install -y sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  #
  # Install OhMyZsh
  && sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" \
  && chsh -s $(which zsh) \
  &&  git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions \
  && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
  #
  # Add Alias
  && echo 'PATH=$PATH:/usr/local/go/bin' >> /root/.zshrc \
  && echo 'alias python=python3' >> /root/.zshrc
#
# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

CMD ["/usr/bin/zsh", "-1"]
