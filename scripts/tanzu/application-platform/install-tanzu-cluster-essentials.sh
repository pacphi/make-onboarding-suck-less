#!/bin/bash
set -e

if  [ -z "$1" ] && [ -z "$2" ] && [ -z "$3" ]; then
	echo "Usage: install-tanzu-cluster-essentials.sh {tanzu-network-api-token} {tanzu-network-username} {tanzu-network-password}"
	exit 1
fi

if ! command -v pivnet &> /dev/null
then
    echo "Downloading pivnet CLI..."
	curl -LO https://github.com/pivotal-cf/pivnet-cli/releases/download/v3.0.1/pivnet-linux-amd64-3.0.1
	chmod +x pivnet-linux-amd64-3.0.1
	sudo mv pivnet-linux-amd64-3.0.1 /usr/local/bin/pivnet
fi


TANZU_NETWORK_API_TOKEN="$1"
TANZU_NETWORK_USERNAME="$2"
TANZU_NETWORK_PASSWORD="$3"

pivnet login --api-token=$TANZU_NETWORK_API_TOKEN

mkdir -p $HOME/tanzu
cd /tmp
TAP_VERSION="1.0.0"
TAP_PRODUCT_FILE_ID=1105818
pivnet download-product-files --product-slug='tanzu-cluster-essentials' --release-version="${TAP_VERSION}" --product-file-id="${TAP_PRODUCT_FILE_ID}"
tar -xvf tanzu-cluster-essentials-linux-amd64-${TAP_VERSION}.tgz -C tanzu-cluster-essentials

export INSTALL_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:82dfaf70656b54dcba0d4def85ccae1578ff27054e7533d08320244af7fb0343
export INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
export INSTALL_REGISTRY_USERNAME='${TANZU_NETWORK_USERNAME}'
export INSTALL_REGISTRY_PASSWORD='${TANZU_NETWORK_PASSWORD}'
cd tanzu-cluster-essentials
./install.sh
