module "managed-zone" {
  source = "git::https://github.com/pacphi/tf4k8s.git//modules/dns/gcp"

  project = var.project
  gcp_service_account_credentials = var.gcp_service_account_credentials
  root_zone_name = var.root_zone_name
  environment_name = var.environment_name
  dns_prefix = var.dns_prefix
}

variable "project" {
  description = "A Google Cloud Platform project id"
  sensitive = true
}

variable "gcp_service_account_credentials" {
  description = "The path to your Google Cloud Platform IAM service account credentials file"
}

variable "root_zone_name" {
  description = "The name of an existing Google Cloud DNS zone; it'll have an NS record added to it referencing the name servers of a new zone"
}

variable "environment_name" {
  description = "An environment name"
}

variable "dns_prefix" {
  description = "Prefix used to create a new domain (e.g., <dns_prefix>.<base-domain>)"
}

output "zone_name" {
  value = module.managed-zone.zone_name
}

output "zone_subdomain" {
  value = module.managed-zone.zone_subdomain
}