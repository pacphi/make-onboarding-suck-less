# Ubuntu 20.10: Docker image

## Prerequistes

* [Docker](https://docs.docker.com/desktop/)

> Notice: [Subscription](https://www.docker.com/blog/updating-product-subscriptions/) is required for buisness use.

## Preparation

(Optional) Fetch Tanzu CLI

```
cp ../scripts/fetch-tanzu-cli.sh .
./fetch-tanzu-cli.sh {VMWUSER} {VMWPASS} linux {TANZU_CLI_VERSION}
```
> Replace `{VMWUSER}` and `{VMWPASS}` with credentials you use to authenticate to https://console.cloud.vmware.com.  Replace `{TANZU_CLI_VERSION}` with a supported (and available) version number for the CLI you wish to embed in the container image.  If your account has been granted access, the script will download a tarball, extract the [Tanzu CLI](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.3/vmware-tanzu-kubernetes-grid-13/GUID-tanzu-cli-reference.html) and place it into a `dist` directory.  The tarball and other content will be discarded.  (The script has "smarts" built-in to determine whether or not to fetch a version of the CLI that may have already been fetched and placed in the `dist` directory).


## Building

If you want to build a portable container image, then execute

```
mkdir -p dist
docker build -t tanzu/k8s-toolkit .
```


## Launching

Execute

```
docker run --rm -it tanzu/k8s-toolkit /bin/bash
```


## Inventory

If you want an inventory of all the relevant tools installed

```
cp ../scripts/inventory.sh .
docker run --rm -v ${PWD}:/home/docker tanzu/k8s-toolkit /bin/bash /home/docker/inventory.sh
```
