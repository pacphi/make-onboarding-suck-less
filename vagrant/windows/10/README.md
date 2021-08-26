# Windows 10: Vagrant Box

## Prerequisites

* vagrant plugin install winrm winrm-fs

## Launching

```
cp ../../../scripts/fetch-tanzu-cli.sh .
cp ../../../scripts/inventory.ps1 .
./fetch-tanzu-cli.sh {VMWUSER} {VMWPASS} windows {TANZU_CLI_VERSION}
vagrant up
```
> Replace `{VMWUSER}` and `{VMWPASS}` with credentials you use to authenticate to https://console.cloud.vmware.com.  Replace `{TANZU_CLI_VERSION}` with a supported (and available) version number for the CLI you wish to embed in the container image.  If your account has been granted access, the script will download a tarball, extract the [Tanzu CLI](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.3/vmware-tanzu-kubernetes-grid-13/GUID-tanzu-cli-reference.html) and place it into a `dist` directory.  The tarball and other content will be discarded.  (The script has "smarts" built-in to determine whether or not to fetch a version of the CLI that may have already been fetched and placed in the `dist` directory).

## Authentication

Login with

* _username_ = `vagrant`
* _password_ = `vagrant`

## Inventory

If you want an inventory of all the relevant tools installed

```
C:\Users\vagrant\inventory.ps1
```
> To be executed inside the VM

## Credit

* [Windows 10](https://app.vagrantup.com/StefanScherer/boxes/windows_10) pulled from Vagrant Cloud
