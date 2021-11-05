#!/bin/bash

sudo apt update -y

# Install VirtualBox
sudo apt-get install lsb_release virtualbox virtualbox-ext-pack -y

# Install Packer and Vagrant
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update -y
sudo apt install packer vagrant -y

CROPT=${1:-nerdctl}

case $CROPT in

  docker)
    # Install Docker
    sudo useradd -m docker && echo "docker:docker" | chpasswd
    adduser docker sudo
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
      "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update -y
    sudo apt install docker-ce docker-ce-cli containerd.io -y
    sudo usermod -aG docker $USER
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    docker run --rm hello-world
    ;;

  nerdtcl)
    cd /tmp
    curl -LO https://github.com/containerd/nerdctl/releases/download/v0.13.0/nerdctl-full-0.13.0-linux-amd64.tar.gz
    sudo tar Cxzvvf /usr/local nerdctl-full-0.13.0-linux-amd64.tar.gz
    sudo systemctl enable --now containerd
    containerd-rootless-setuptool.sh install
    containerd-rootless-setuptool.sh install-buildkit
    nerdctl container run --rm hello-world
    ;;

esac


