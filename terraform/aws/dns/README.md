# Terraform for creating AWS Route53 DNS managed zone and NS recordset

Oftentimes, you'll have the requirement to add and manage DNS sub-domains.

Assumes:

* your authoritative names servers and DNS record information is managed external to Amazon Web Services
* a managed zone (known as the "root zone") has already been set up in Amazon Web Services Route53


## Copy sample configuration

```
cp terraform.tfvars.sample terraform.tfvars
```

## Edit `terraform.tfvars`

Amend the values for

* `base_hosted_zone_id`
* `domain_prefix`
* `region`

## Create a zone

All we're doing here is creating a new managed zone and adding an NS record to the "root zone".

```
./create-zone.sh
```


## Teardown zone

```
./destroy-zone.sh
```
