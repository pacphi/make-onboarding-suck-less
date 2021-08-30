# Build an Azure Virtual Machine Image

## Prerequisites

* Azure account credentials
* [az CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
* [Packer](https://www.packer.io/downloads)


## Authenticate

### Use existing account

```
az login
```

### (Optional) Create a service principal

```
RESOURCE_GROUP={RESOURCE_GROUP}
SUBSCRIPTION_ID={SUBSCRIPTION_ID}
TENANT_ID={TENANT_ID}
CLIENT_SECRET={CLIENT_SECRET}
APP_NAME={SERVICE_PRINCIPAL_NAME}
az account set -s $SUBSCRIPTION_ID
az ad app create --display-name $APP_NAME --homepage "http://localhost/$APP_NAME"
APP_ID=$(az ad app list --display-name $APP_NAME | jq '.[0].appId' | tr -d '"')
az ad sp create-for-rbac --name $APP_ID --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP"
az ad sp credential reset --name "$APP_ID" --password "${CLIENT_SECRET}"
CLIENT_ID=$(az ad sp list --display-name $APP_ID | jq '.[0].appId' | tr -d '"')
az role assignment create --assignee "$CLIENT_ID" --role "Owner" --subscription "$SUBSCRIPTION_ID"
```
> Replace `{RESOURCE_GROUP}` with an existing resource group name; a [resource group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal) is nothing more than a container for related resources.  Replace `{SUBSCRIPTION_ID}` with the id of your Azure subscription. Replace `{TENANT_ID}` with the tenant identifier.  To find the default subscription and tenant id type `az account list --query "[?isDefault]"`.  Replace `{CLIENT_SECRET}` with any alpha-numeric set of characters (and this secret must be 8 or more characters in length).  Replace `{SERVICE_PRINCIPAL_NAME}` with any alpha-numeric set of characters (and this name must also be 8 or more characters in length).

### (Optional) Login with service principal

```
az login --service-principal --username {APP_ID} --password {CLIENT_SECRET} --tenant {TENANT_ID}
```
> Replace `{APP_ID}`, `{CLIENT_SECRET}`, and `{TENANT_ID}` with the values you used to create the service principal above.


## Use Packer to build and upload an Azure Virtual Machine Image

Copy common scripts into place

```
cp ../../../../scripts/init.sh .
cp ../../../../scripts/kind-load-cafile.sh .
cp ../../../../scripts/inventory.sh .
cp ../../../../scripts/fetch-tanzu-cli.sh .
```

Fetch Tanzu CLI

```
./fetch-tanzu-cli.sh {VMWUSER} {VMWPASS} linux {TANZU_CLI_VERSION}
```
> Replace `{VMWUSER}` and `{VMWPASS}` with credentials you use to authenticate to https://console.cloud.vmware.com.  Replace `{TANZU_CLI_VERSION}` with a supported (and available) version number for the CLI you wish to embed in the container image.  If your account has been granted access, the script will download a tarball, extract the [Tanzu CLI](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.3/vmware-tanzu-kubernetes-grid-13/GUID-tanzu-cli-reference.html) and place it into a `dist` directory.  The tarball and other content will be discarded.  (The script has "smarts" built-in to determine whether or not to fetch a version of the CLI that may have already been fetched and placed in the `dist` directory).

Type the following to build the AMI

```
packer init .
packer fmt .
packer validate .
packer inspect .
packer build .
```
> In ~10 minutes you should notice a `manifest.json` file where within the `artifact_id` contains a reference to the AMI ID.


### Available overrides

You may wish to size the instance and/or choose a different region to host the AMI.

```
packer build --var vm_size="Standard_A4" --var location="eastus2" .
```
> Consult the `variable` blocks inside [arm.pkr.hcl](arm.pkr.hcl)



## For your consideration

* [Azure Virtual Machine Builders](https://www.packer.io/docs/builders/azure)
