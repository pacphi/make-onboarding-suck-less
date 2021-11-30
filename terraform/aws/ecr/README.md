# Terraform an Elastic Container Registry

Based on the following Terraform [example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_repository).

Assumes:

* IAM user has been created with appropriate role and permissions to create a container registry


## Copy sample configuration

```
cp terraform.tfvars.sample terraform.tfvars
```


## Edit `terraform.tfvars`

Amend the values for

* `registry_name`


## Create the registry

```
./create-registry.sh
```


## Teardown the registry

```
./destroy-registry.sh
```
