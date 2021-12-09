#!/bin/bash
set -e

if [ -z "$1" ]; then
	echo "Usage: fetch-tap-gui-catalog.sh {tanzu-network-api-token}"
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

cd /tmp
TAP_VERSION="0.4.0"
TAP_PRODUCT_FILE_ID=1099786
pivnet download-product-files --product-slug='tanzu-application-platform' --release-version="${TAP_VERSION}" --product-file-id="${TAP_PRODUCT_FILE_ID}"
ls -la tap-gui-blank-catalog.tgz


echo "Unpack the contents of this file, initialize a Git repository, commit the source and push to a repository of record (e.g., Github)."
