# Terraform for creating Cloud DNS managed zone and NS recordset

Oftentimes, you'll have the requirement to add and manage DNS sub-domains.

Assumes:

* your authoritative names servers and DNS record information is managed external to Google Cloud DNS
* a managed zone (known as the "root zone") has already been set up in Google Cloud DNS

## Copy sample configuration

```
cp terraform.tfvars.sample terraform.tfvars
```

## Edit `terraform.tfvars`

Amend the values for

* `project`
* `gcp_service_account_credentials`
* `root_zone_name`
* `environment_name`
* `dns_prefix`


## Create a zone

All we're doing here is creating a new managed zone and adding an NS record to the "root zone".

```
./create-zone.sh
```

## Teardown zone

```
./destroy-zone.sh
```
