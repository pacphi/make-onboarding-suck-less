# Build an Oracle Cloud Infrastructure Image

## Prerequisites

* Oracle Cloud service account credentials
* Oracle Cloud CLI ([oci](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm#Quickstart))
* [Packer](https://www.packer.io/downloads)


## Authenticate

A number of options exist, but this simplest may be to

```
oci setup config
```

You will be prompted for

* User OCID
  * to be found under `Profile > User Settings`
* Tenancy OCID
  * to be found under `Profile > Tenancy: {account_name}`
* Key file directory
 * just accept the default location
* Region
  * you will be prompted with several options

You will need to upload the public key.

Next, consult

* [Required Keys and OCIDs](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm)
* [Managing IAM](https://docs.oracle.com/en-us/iaas/Content/Identity/iam/manage-iam.htm?Highlight=iam)
* [Virtual Cloud Network (VCN) Management](https://docs.oracle.com/en-us/iaas/Content/Rover/Network/VCN/vcn_management.htm)
* [Subnet Management](https://docs.oracle.com/en-us/iaas/Content/Rover/Network/Subnet/subnet_management.htm?Highlight=subnet)


## Upload Public key

From the hamburger menu in the upper left-hand corner, visit `Identity & Security > Users`.  Then click on a user.  Then click on `Resources > API Keys`.  Finally, click on the `Add API Key` button and follow the prompts to complete uploading your public key (.pem) file.

> See [How to Upload the Public Key](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#How2)


## Create Compartment

```
oci iam compartment create --compartment-id {parent_compartment_ocid} --description "{new_compartment_description}" --name {new_compartment_name}
```
> Replace `{parent_compartment_ocid}`, `{new_compartment_description}` and `{new_compartment_name}` with the root compartment OCID, description for the new compartment and the new compartment name respectively

For example

```
oci iam compartment create --compartment-id ocid1.tenancy.oc1..aaaaaaaa --description "Tanzu Application Platform Compartment" --name tap
```

Make a note of the new compartment's OCID (i.e., `id`) in the JSON output returned.


## Verify setup

Do a quick API call request to confirm your setup is valid

```
oci iam availability-domain list --output table
```


## Create VCN and Subnets

### from Cloud Console

If you're looking for a straight-forward tutorial on how to do this from the cloud console, then take a look at:

* [How to Create Virtual Cloud Network (VCN) in Oracle Cloud Infrastructure (OCI)](https://nimishprabhu.com/how-to-create-virtual-cloud-network-vcn-in-oracle-cloud-infrastructure-oci.html)
* [How to Create Subnets in Oracle Cloud Infrastructure (OCI)](https://nimishprabhu.com/how-to-create-subnets-in-oracle-cloud-infrastructure-oci.html)

### from oci CLI

If you're looking to do this from the CLI, set the environment variables below:

```
export VCN_COMPARTMENT_OCID="ocid1.tenancy.oc1..aaaaaaaa"
export VCN_CIDR_BLOCK="10.0.1.0/24"
export VCN_DISPLAY_NAME="TAP-VCN"
export VCN_DNS_LABEL="tap-vcn"
export SUBNET_CIDR_BLOCK="10.0.1.0/26"
export SUBNET_DISPLAY_NAME="TAP-SUB-01"
export SUBNET_DNS_LABEL="tap-sub-01"
```

Then execute:

```
oci network vcn create \
  --cidr-block ${VCN_CIDR_BLOCK} \
  --compartment-id ${VCN_COMPARTMENT_OCID} \
  --display-name ${VCN_DISPLAY_NAME} \
  --dns-label ${VCN_DNS_LABEL}

export VCN_OCID=$(oci network vcn list -c ${VCN_COMPARTMENT_OCID} --query "data [?\"display-name\"==\`${VCN_DISPLAY_NAME}\`] | [0].id" --raw-output)

echo "==== Created VCN details ===="
oci network vcn list -c ${VCN_COMPARTMENT_OCID} --output table --query "data [?contains(\"display-name\",\`${VCN_DISPLAY_NAME}\`)].{CIDR:\"cidr-block\", VCN_NAME:\"display-name\", DOMAIN_NAME:\"vcn-domain-name\", DNS:\"dns-label\"}"
echo
echo "delete command ==>  oci network vcn delete --vcn-id ${VCN_OCID}" --force

oci network subnet create \
  --cidr-block ${SUBNET_CIDR_BLOCK} \
  --compartment-id ${VCN_COMPARTMENT_OCID} \
  --vcn-id ${VCN_OCID} \
  --display-name ${SUBNET_DISPLAY_NAME} \
  --dns-label ${SUBNET_DNS_LABEL} \
  --prohibit-public-ip-on-vnic false

export SUBNET_OCID=$(oci network subnet list -c ${VCN_COMPARTMENT_OCID} --vcn-id ${VCN_OCID} --query "data[?contains(\"display-name\",\`${SUBNET_DISPLAY_NAME}\`)]|[0].id" --raw-output)

echo "==== Created SUBNET details ===="
oci network subnet list -c ${VCN_COMPARTMENT_OCID} --vcn-id ${VCN_OCID} --query "data[*].{SUBNAME:\"display-name\",SUB_CIDR:\"cidr-block\",subdomain:\"subnet-domain-name\",SUB_OCID:id}" --output table
echo
echo "delete command ==>  oci network subnet delete --subnet-id ${SUBNET_OCID}" --force
```

> You might consider creating multiple subnets.  If you started with 10.0.1.0/26, then you could specify 10.0.1.64/26 and 10.0.1.128/26 to provision a trio of IP address ranges, each with 64 IP addresses.

### from Terraform

Or you might want to use Terraform

// TODO Insert procedure for leveraging terraform/oci modules


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
> Replace `{VMWUSER}` and `{VMWPASS}` with credentials you use to authenticate to https://console.cloud.vmware.com.  Replace `{TANZU_CLI_VERSION}` with a supported (and available) version number for the CLI you wish to embed in the container image.  If your account has been granted access, the script will download a tarball, extract the [Tanzu CLI](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-tanzu-cli-reference.html) and place it into a `dist` directory.  The tarball and other content will be discarded.  (The script has "smarts" built-in to determine whether or not to fetch a version of the CLI that may have already been fetched and placed in the `dist` directory).

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
packer build --var  --var  .
```
> Consult the `variable` blocks inside [oci.pkr.hcl](oci.pkr.hcl)



## For your consideration

* [Oracle Cloud](https://www.packer.io/docs/builders/oracle/oci) Builder
* [Oracle Cloud CLI Reference](https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/index.html)
* [Launch an OCI Instance with OCI-CLI in 10 minutes](https://eclipsys.ca/launch-an-oci-instance-with-oci-cli-in-10-minutes/)