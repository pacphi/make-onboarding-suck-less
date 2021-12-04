# Terraform for creating Azure DNS managed zone and NS recordset

Oftentimes, you'll have the requirement to add and manage DNS sub-domains.

Assumes:

* your authoritative names servers and DNS record information is managed external to Microsoft Azure
* a managed zone (known as the "root zone") has already been set up in Azure DNS.
* resource group already exists

## Copy sample configuration

```
cp terraform.tfvars.sample terraform.tfvars
```

## Edit `terraform.tfvars`

Amend the values for

* `base_domain`
* `domain_prefix`
* `resource_group_name`
* `az_subscription_id`
* `az_client_id`
* `az_client_secret`
* `az_tenant_id`

## Create a zone

All we're doing here is creating a new managed zone and adding an NS record to the "root zone".

```
./create-zone.sh
```

## Teardown zone

```
./destroy-zone.sh
```
