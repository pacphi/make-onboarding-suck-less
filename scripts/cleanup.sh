#!/usr/bin/env bash

# Cleans up redundant scripts found in vagrant directories
# Must be executed from root of this repository (e.g. ./scripts/cleanup.sh)
rm -Rf docker/fetch-tanzu-cli.sh vagrant/ubuntu/20_04/fetch-tanzu-cli.sh vagrant/macos/10_15/fetch-tanzu-cli.sh
rm -Rf vagrant/ubuntu/20_04/inventory.sh vagrant/macos/10_15/inventory.sh
