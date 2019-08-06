FROM ubuntu:latest

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Terraform and tflint versions
ARG TERRAFORM_VERSION=0.12.5
ARG TFLINT_VERSION=0.9.3

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
  # Install OhMyZsh
  && sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" \
  && chsh -s $(which zsh) \
  #
  # Install Go
  && wget -q https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz -O go1.12.7.linux-amd64.tar.gz \
  && tar -C /usr/local -xzf go1.12.7.linux-amd64.tar.gz \
  && echo 'PATH=$PATH:/usr/local/go/bin' >> /root/.zshrc

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

CMD ["/usr/bin/zsh", "-1"]
