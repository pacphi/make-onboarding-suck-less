#!/usr/bin/env bash

# Cleans up redundant scripts found in vagrant directories
# Must be executed from root of this repository (e.g. ./scripts/cleanup.sh)
rm -Rf docker/*.sh vagrant/ubuntu/20_04/*.sh vagrant/macos/10_15/*.sh vagrant/windows/10/*.ps1 vagrant/windows/10/*.sh
rm -Rf docker/dist vagrant/ubuntu/20_04/dist vagrant/macos/10_15/dist vagrant/windows/10/dist
rm -Rf vagrant/ubuntu/20_04/.vagrant vagrant/macos/10_15/.vagrant vagrant/windows/10/.vagrant
rm -Rf packer/aws/ubuntu/20_04/dist packer/azure/ubuntu/20_04/dist packer/google/ubuntu/20_04/dist
rm -Rf packer/aws/ubuntu/20_04/*.sh packer/azure/ubuntu/20_04/*.sh packer/google/ubuntu/20_04/*.sh
rm -Rf packer/aws/ubuntu/20_04/*.json packer/azure/ubuntu/20_04/*.json packer/google/ubuntu/20_04/*.json
