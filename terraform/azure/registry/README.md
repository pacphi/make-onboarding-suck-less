# Terraform for creating a Microsoft Registry

Sometimes you need a place to put your container images.  Why not use Microsoft Azure's registry?

Starts with the assumption that you will use a service principals's credentials that has appropriate role/permissions to create/destroy a Microsoft Azure Container Registry.  (Note: destroying this resource does not destroy the backing bucket).

## Copy sample configuration

```
cp terraform.tfvars.sample terraform.tfvars
```

## Edit `terraform.tfvars`

Amend the values for

* `registry_name`
* `location`
* `resource_group_name`
* `az_subscription_id`
* `az_client_id`
* `az_client_secret`
* `az_tenant_id`

> Note: A resource group with `resource_group_name` should already exist.

## Create

```
./create-registry.sh
```

## Use

Login with Docker CLI

```
docker login --password-stdin $(terraform output acr_admin_password | tr -d '"') -u $(terraform output acr_admin_username | tr -d '"') $(terraform output acr_url | tr -d '"')
```

## Destroy

To tear it down

```
./destroy-registry.sh
```
