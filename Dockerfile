FROM ubuntu:latest

# Install Azure-CLI
RUN apt-get update && \
  apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive && \
  apt-get install -y \
  apt-utils \
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
  vim

RUN  curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install .NET
RUN wget -q https://packages.microsoft.com/config/ubuntu/19.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
  dpkg -i packages-microsoft-prod.deb && \
  apt-get update && \
  apt-get install dotnet-sdk-2.2 -y

# Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
  apt-get install -y nodejs -y

# Install Terraform

# Install OhMyZsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" && \
  chsh -s $(which zsh)

# Install Go
RUN wget -q https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz -O go1.12.7.linux-amd64.tar.gz && \
  tar -C /usr/local -xzf go1.12.7.linux-amd64.tar.gz && \
  echo 'PATH=$PATH:/usr/local/go/bin' >> /root/.zshrc

CMD ["/usr/bin/zsh", "-1"]
