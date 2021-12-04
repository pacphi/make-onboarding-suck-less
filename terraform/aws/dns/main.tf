module "managed-zone" {
  source = "git::https://github.com/pacphi/tf4k8s.git//modules/dns/amazon"

  base_hosted_zone_id = var.base_hosted_zone_id
  domain_prefix = var.domain_prefix
  region = var.region
}

variable "base_hosted_zone_id" {
  description = "The id of an existing Route53 zone; it'll have an NS record added to it referencing the name servers of a new zone"
}

variable "domain_prefix" {
  description = "Prefix for a domain (e.g. in lab.cloudmonk.me, 'lab' is the prefix)"
}

variable "region" {
  description = "An AWS region (e.g., us-east-1)"
  default = "us-west-2"
}

output "sub_domain" {
  description = "New sub domain"
  value = module.managed-zone.base_domain
}

output "hosted_zone_id" {
  value = module.managed-zone.hosted_zone_id
}
