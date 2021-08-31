#!/bin/bash

# Install Homebrew; @see https://brew.sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Install VirtualBox
brew install --cask virtualbox

# Install Vagrant
brew install --cask vagrant

# Install Packer
brew install packer

# Install Docker
brew install --cask docker

# Install vmw-cli
brew install node
npm install vmw-cli --global
