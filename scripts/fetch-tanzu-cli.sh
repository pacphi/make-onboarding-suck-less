#!/usr/bin/env bash

if [ -z "$1" ] && [ -z "$2" ] && [ -z "$3" ] && [ -z "$4" ]; then
	echo "Usage: fetch-tanzu-cli.sh {username} {password} {os} {tanzu-cli-version}"
	exit 1
fi

VMWUSER="$1"
VMWPASS="$2"
OS="$3"
TANZU_VERSION="$4"

FILE=tanzu-cli-bundle-${OS}-amd64.tar
CURRENT_VERSION="latest"
DIST_EXECUTABLE="dist/tanzu"
TANZU_CLI="tanzu"
if [ "$OS" == "windows" ]; then
  TANZU_CLI = "tanzu.exe"
  DIST_EXECUTABLE = "dist/tanzu.exe"
fi
if [ -e "$DIST_EXECUTABLE" ]; then
  cd dist
  TANZU_CLI_VERSION_OUTPUT=$(${TANZU_CLI} version)
  MULTI_LINE_STRING=${TANZU_CLI_VERSION_OUTPUT#"version: v"}
  OUTPUT_ARRAY=(${MULTI_LINE_STRING[@]})
  CURRENT_VERSION=${OUTPUT_ARRAY[0]}
  cd ..
fi

if [ "$TANZU_VERSION" == "$CURRENT_VERSION" ]; then
    echo "$FILE already downloaded."
else
    echo "$FILE does not exist. Will begin fetching from https://console.cloud.vmware.com."
    mkdir -p dist
    docker run -itd --name vmw -e VMWUSER=${VMWUSER} -e VMWPASS=${VMWPASS} -v ${PWD}:/files --entrypoint=sh apnex/vmw-cli
    docker exec -t vmw vmw-cli ls vmware_tanzu_kubernetes_grid
    docker exec -t vmw vmw-cli cp $FILE
    tar xvf $FILE -C dist
    if [ "$OS" == "windows" ]; then
      cp dist/cli/core/v${TANZU_VERSION}/tanzu-core-${OS}_amd64.exe ${DIST_EXECUTABLE}
    else
      chmod +x dist/cli/core/v${TANZU_VERSION}/tanzu-core-${OS}_amd64
      cp dist/cli/core/v${TANZU_VERSION}/tanzu-core-${OS}_amd64 ${DIST_EXECUTABLE}
    fi
    rm -Rf dist/cli
    mv $FILE dist
    docker rm -f vmw
fi
