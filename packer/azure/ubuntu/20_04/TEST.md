# Creating an Azure VM from a custom image

## Prerequisites

* Azure account credentials
* [az CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)


## Create a VM instance

```
az vm create \
   --resource-group {RESOURCE_GROUP} \
   --name {INSTANCE_NAME} \
   --image {MANAGED_IMAGE_ID} \
   --admin-username ubuntu
   --generate-ssh-keys
```
> Replace `{RESOURCE_GROUP}` with an existing resource group name.  Replace `{INSTANCE_NAME}` with any alpha-numeric set of characters (and this name must be 8 or more characters in length).  Replace `{MANAGED_IMAGE_ID}` with the value of `ManagedImageId:` the was logged after you executed a `packer build`.

For example

```
❯ az vm create \
    --resource-group cloudmonk \
    --name K8sToolSetTest \
    --image /subscriptions/bee31e51-b8ae-4c3d-9736-9ee2b9a0e344/resourceGroups/cloudmonk/providers/Microsoft.Compute/galleries/toolsetvms/images/SpringOne2021K8sToolsetImage/versions/2022.1.26 \
    --admin-username ubuntu \
    --generate-ssh-keys

SSH key files '/home/cphillipson/.ssh/id_rsa' and '/home/cphillipson/.ssh/id_rsa.pub' have been generated under ~/.ssh to allow SSH access to the VM. If using machines without permanent storage, back up your keys to a safe location.
It is recommended to use parameter "--public-ip-sku Standard" to create new VM with Standard public IP. Please note that the default public IP used for VM creation will be changed from Basic to Standard in the future.

{
  "fqdns": "",
  "id": "/subscriptions/bee31e51-b8ae-4c3d-9736-9ee2b9a0e344/resourceGroups/cloudmonk/providers/Microsoft.Compute/virtualMachines/K8sToolSetTest",
  "location": "westcentralus",
  "macAddress": "00-22-48-5D-84-15",
  "powerState": "VM running",
  "privateIpAddress": "10.0.0.4",
  "publicIpAddress": "13.78.236.67",
  "resourceGroup": "cloudmonk",
  "zones": ""
}
```


## Connect to the instance

```
ssh -i $HOME/.ssh/id_sra ubuntu@{PUBLIC_IP_ADDRESS}
```
> You were paying attention weren't you? The `{PUBLIC_IP_ADDRESS}` is available from the output of the prior command you issued.


## On using the Tanzu CLI

One time setup

You will need to install the plugins the Tanzu CLI requires after connecting by exploding the tarball and executing `tanzu plugin install --local cli all`


## Credit

* [Create a VM from a generalized image version using the Azure CLI](https://docs.microsoft.com/en-us/azure/virtual-machines/vm-generalized-image-version-cli)
* [az ssh](https://docs.microsoft.com/en-us/cli/azure/ssh?view=azure-cli-latest#az_ssh_config)
