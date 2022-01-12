# Creating a VM from an Oracle Cloud Infrastructure Image

## Prerequisites

* Oracle Cloud service account credentials
* Oracle Cloud CLI ([oci](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm#Quickstart))
* Terraform CLI ([terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform))


## Authenticate

If you haven't already configured the oci CLI, consult the steps from the [build](BUILD.md#authenticate) documentation.


## Create VM

```
cd ../../../
cd terraform/oci/compute-instance
cp terraform.tfvars.sample terraform.tfvars
# Edit the contents of terraform.tfvars
## At minimum you'll need to specify the OCIDs for the source image and subnet
./create-compute-instance.sh
```

## Connect to VM

```
ssh ubuntu@{PUBLIC_IP_ADDRESS_OF_COMPUTE_INSTANCE}
```
> Replace `{PUBLIC_IP_ADDRESS_OF_COMPUTE_INSTANCE}` with a real IP address for a running compute instance in an Oracle Cloud Infrastructure account


## On using the Tanzu CLI

One time setup

You will need to install the plugins the Tanzu CLI requires after connecting by exploding the tarball and executing `tanzu plugin install --local cli all`


## Destroy VM

```
cd ../../../
cd terraform/oci/compute-instance
./destroy--compute-instance.sh
```
