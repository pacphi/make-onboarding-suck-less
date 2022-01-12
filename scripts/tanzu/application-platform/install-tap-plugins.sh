#!/bin/bash
set -e

if [ -z "$1" ]; then
	echo "Usage: install-tap-plugins.sh {tanzu-network-api-token}"
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
pivnet login --api-token=$TANZU_NETWORK_API_TOKEN

mkdir -p $HOME/tanzu
cd /tmp
TAP_VERSION="0.4.0-build.13"
TAP_PRODUCT_FILE_ID=1100110
pivnet download-product-files --product-slug='tanzu-application-platform' --release-version="${TAP_VERSION}" --product-file-id="${TAP_PRODUCT_FILE_ID}"
tar -xvf tanzu-framework-linux-amd64.tar -C $HOME/tanzu

cd $HOME/tanzu
tanzu plugin delete package
tanzu plugin install secret --local ./cli
tanzu plugin install accelerator --local ./cli
tanzu plugin install apps --local ./cli
tanzu plugin install package --local ./cli
tanzu plugin list
tanzu version
