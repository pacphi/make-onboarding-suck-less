# Build an AMI

## Prerequisites

* AWS administrator account credentials
* [aws CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
* [Packer](https://www.packer.io/downloads)


## Export AWS credentials

Add your AWS credentials as two environment variables, `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, replacing `<YOUR_ACCESS_KEY>` and `<YOUR_SECRET_KEY>` with their respective values.

```
export AWS_ACCESS_KEY_ID=<YOUR_ACCESS_KEY>
export AWS_SECRET_ACCESS_KEY=<YOUR_SECRET_KEY>
```


## Use Packer to build and upload an AMI to an AWS region

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

>In ~10 minutes you should notice a `manifest.json` file where within the `artifact_id` contains a reference to the image ID.


### Available overrides

You may wish to size the instance and/or choose a different region to host the image.

```
packer build --var instance_type=m4.xlarge --var vpc_region=eu-west-3 -only='standard.*' .
```
> Consult the `variable` blocks inside [ami.pkr.hcl](ami.pkr.hcl)



## For your consideration

* [Packer and AWS: Tutorial - Build an image](https://learn.hashicorp.com/tutorials/packer/aws-get-started-build-image?in=packer/aws-get-started)
* [Amazon EC2 AMI Locator](https://cloud-images.ubuntu.com/locator/ec2/)
  * Ubuntu 20.04 AMD ebs-ssd images
    * us-east-1 - ami-019212a8baeffb0fa
    * us-west-2 - ami-02868af3c3df4b3aa
    * eu-west-3 - ami-06d3fffafe8d48b35
* [Amazon AMI Builder](https://www.packer.io/docs/builders/amazon)
* [AMI Builder (EBS backed)](https://www.packer.io/docs/builders/amazon/ebs)
