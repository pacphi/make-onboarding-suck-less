# Terraform for creating a Google Container Registry

Sometimes you need a place to put your container images.  Why not use Google Cloud Platform's registry?

Starts with the assumption that you will use a service account's credentials that has appropriate role/permissions (i.e., `roles/storage.admin`) to create/destroy a Google Container Registry.  (Note: destroying this resource does not destroy the backing bucket).

## Copy sample configuration

```
cp terraform.tfvars.sample terraform.tfvars
```

## Edit `terraform.tfvars`

Amend the values for

* `project`
* `location`
* `gcp_service_credentials`

## Create

```
./create-registry.sh
```

## Use

Login with Docker CLI

```
docker login -u _json_key -p "$(cat /path/to/keyfile.json)" $(terraform output gcr_repository_url | tr -d '"')
```

## Destroy

To tear it down

```
./destroy-registry.sh
```
