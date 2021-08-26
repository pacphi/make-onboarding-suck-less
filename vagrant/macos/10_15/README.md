# MacOS 10.15: Vagrant Box

## Launching

```
cp ../../../scripts/fetch-tanzu-cli.sh .
cp ../../../scripts/inventory.sh .
./fetch-tanzu-cli.sh {VMWUSER} {VMWPASS} darwin {TANZU_CLI_VERSION}
vagrant up
```
> Replace `{VMWUSER}` and `{VMWPASS}` with credentials you use to authenticate to https://console.cloud.vmware.com.  Replace `{TANZU_CLI_VERSION}` with a supported (and available) version number for the CLI you wish to embed in the container image.  If your account has been granted access, the script will download a tarball, extract the [Tanzu CLI](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.3/vmware-tanzu-kubernetes-grid-13/GUID-tanzu-cli-reference.html) and place it into a `dist` directory.  The tarball and other content will be discarded.  (The script has "smarts" built-in to determine whether or not to fetch a version of the CLI that may have already been fetched and placed in the `dist` directory).

Be patient! Particularly while waiting for Homebrew package management to install. It may appear that the provisioning script is hung, but it's not.  (Could take up to 15 minutes before proceeding with remaining lines of the inline script).

## Authentication

Login with

* _username_ = `vagrant`
* _password_ = `vagrant`

## Inventory

If you want an inventory of all the relevant tools installed

```
$HOME/inventory.sh
```
> To be executed inside the VM

## Troubleshooting

When shutting down from VirtualBox UI if VM fails to shutdown...

```
ps -eaf | grep VBoxHeadless
kill -9 {pid}
VBoxManage list vms
VBoxManage unregistervm {image-uuid} --delete
```

## Credit

* [MacOS 10.15](https://app.vagrantup.com/VMR/boxes/MacOS_Catalina-R) pulled from Vagrant Cloud