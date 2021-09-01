# Build a Google Compute Image

## Prerequisites

* Google Compute service account credentials
* Google Cloud SDK ([gcloud](https://cloud.google.com/sdk/docs/install))
* [Packer](https://www.packer.io/downloads)


## Authenticate

A number of options exist, but this simplest may be to

```
gcloud auth application-default login
```

Then if you're on MacOs or Linux

```
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/application_default_credentials.json"
```

or Windows

```
export GOOGLE_APPLICATION_CREDENTIALS="%APPDATA%/gcloud/application_default_credentials.json"
```


## Use Packer to build and start a VM in a designated region and availability zone

Copy common scripts into place

```
cp ../../../../scripts/init.sh .
cp ../../../../scripts/kind-load-cafile.sh .
cp ../../../../scripts/inventory.sh .
```

(Optional) Fetch Tanzu CLI

```
cp ../../../../scripts/fetch-tanzu-cli.sh .
./fetch-tanzu-cli.sh {VMWUSER} {VMWPASS} linux {TANZU_CLI_VERSION}
```
> Replace `{VMWUSER}` and `{VMWPASS}` with credentials you use to authenticate to https://console.cloud.vmware.com.  Replace `{TANZU_CLI_VERSION}` with a supported (and available) version number for the CLI you wish to embed in the container image.  If your account has been granted access, the script will download a tarball, extract the [Tanzu CLI](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.3/vmware-tanzu-kubernetes-grid-13/GUID-tanzu-cli-reference.html) and place it into a `dist` directory.  The tarball and other content will be discarded.  (The script has "smarts" built-in to determine whether or not to fetch a version of the CLI that may have already been fetched and placed in the `dist` directory).

Type the following to build the image

```
packer init .
packer fmt .
packer validate .
packer inspect .
packer build -only='{BUILD_NAME}.*' .
```
> Replace `{BUILD_NAME}` with one of [ `standard`, `with-tanzu` ]; a file provisioner uploads the Tanzu CLI into your image when set to `with-tanzu`.  You have the option post image build to fetch and install or upgrade it via [vmw-cli](https://github.com/apnex/vmw-cli).  The [fetch-tanzu-cli.sh](../../../../scripts/fetch-tanzu-cli.sh) script is also packaged and available for your convenience in the resultant image.

>In ~10 minutes you should notice a `manifest.json` file where within the `artifact_id` contains a reference to the AMI ID.


### Available overrides

You may wish to size the instance and/or choose a different region to host the image.

```
packer build --var project_id=fe-cphillipson --var zone=europe-central2-a -only='standard.*' .
```
> Consult the `variable` blocks inside [googlecompute.pkr.hcl](googlecompute.pkr.hcl)



## For your consideration

* [Google Compute](https://www.packer.io/docs/builders/googlecompute) Builder
