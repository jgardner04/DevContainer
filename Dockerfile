FROM ubuntu:latest

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# This Dockerfile adds a non-root 'vscode' user with sudo access. However, for Linux,
# this user's GID/UID must match your local user UID/GID to avoid permission issues
# with bind mounts. Update USER_UID / USER_GID if yours is not 1000. See
# https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=jogardn
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Terraform and tflint versions
ARG TERRAFORM_VERSION=0.12.6
ARG TFLINT_VERSION=0.9.3
ARG PACKER_VERSION=1.4.3


# Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  # Add sudo support
  && apt-get update \
  && apt-get install -y sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME

USER ${USERNAME}

WORKDIR /home/jogardn

# Install Basic Packages
RUN sudo apt-get -y upgrade \
  && sudo apt-get -y install apt-utils \
  && sudo apt-get -y install \
  ca-certificates \
  curl \
  apt-transport-https \
  lsb-release \
  gnupg \
  gettext \
  wget \
  gpg \
  git \
  zsh \
  tmux \
  jq \
  vim \
  unzip \
  zip \
  build-essential
#
# Install Kubectl
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - \
  && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list \
  && sudo apt-get update \
  && sudo apt-get install -y kubectl
#
# Install Helm
RUN mkdir -p /tmp/helm-downloads \
  && sudo curl -sSL -o /tmp/helm-downloads/get_helm.sh https://git.io/get_helm.sh \
  && sudo chmod 700 /tmp/helm-downloads/get_helm.sh \
  && sudo /tmp/helm-downloads/get_helm.sh
#
# Install Azure CLI
RUN mkdir -p /tmp/azure-cli \
  && cd /tmp/azure-cli \
  && curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
#
# Install Terraform, tflint, and graphviz
RUN mkdir -p /tmp/docker-downloads \
  && curl -sSL -o /tmp/docker-downloads/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && sudo unzip /tmp/docker-downloads/terraform.zip \
  && sudo mv terraform /usr/local/bin \
  && curl -sSL -o /tmp/docker-downloads/tflint.zip https://github.com/wata727/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip \
  && sudo unzip /tmp/docker-downloads/tflint.zip \
  && sudo mv tflint /usr/local/bin \
  && export PATH=/usr/local/tflint/bin:$PATH \
  && cd ~ \
  && rm -rf /tmp/docker-downloads \
  && sudo apt-get install -y graphviz
#
# Install Packer
RUN sudo mkdir -p /tmp/hashicorp-downloads \
  && sudo curl -sSL -o /tmp/hashicorp-downloads/packer.zip https://releases.hashicorp.com/packer/1.4.3/packer_${PACKER_VERSION}_linux_amd64.zip \
  && sudo unzip /tmp/hashicorp-downloads/packer.zip \
  && sudo mv packer /usr/local/bin
#
# Install .NET
RUN mkdir /tmp/dotnet-downloads \
  && sudo wget -q https://packages.microsoft.com/config/ubuntu/19.04/packages-microsoft-prod.deb -O /tmp/dotnet-downloads/packages-microsoft-prod.deb \
  && sudo dpkg -i /tmp/dotnet-downloads/packages-microsoft-prod.deb \
  && sudo apt-get update \
  && sudo apt-get install dotnet-sdk-2.2 -y
#
# Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_12.x | sudo bash - \
  && sudo apt-get -y install nodejs
#
# Install Go
RUN mkdir /tmp/go-downloads \
  && sudo wget -q https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz -O /tmp/go-downloads/go1.12.7.linux-amd64.tar.gz \
  && sudo tar -C /usr/local -xzf /tmp/go-downloads/go1.12.7.linux-amd64.tar.gz \
  && echo 'PATH=$PATH:/usr/local/go/bin'
#
# Install Go tools
RUN /usr/local/go/bin/go get -u -v \
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
  github.com/derekparker/delve/cmd/dlv 2>&1
#
# Install OhMyZsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" \
  && sudo chsh -s $(which zsh) \
  &&  git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions \
  && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
  && git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
#
# Add ZSH Config file
RUN mv /home/$USERNAME/.zshrc /home/$USERNAME/.zshrc.orig
COPY --chown=$USERNAME .zshrc /home/$USERNAME/.zshrc
COPY --chown=$USERNAME .p10k.zsh /home/$USERNAME/.p10k.zsh

#
# Add Alias
RUN echo 'PATH=$PATH:/usr/local/go/bin' >> /home/$USERNAME/.zshrc \
  && echo 'export PATH=/usr/local/tflint/bin:$PATH' >> /home/$USERNAME/.zshrc \
  & echo 'alias python=python3' >> /home/$USERNAME/.zshrc

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

ENTRYPOINT [ "tail", "-f", "/dev/null" ]
