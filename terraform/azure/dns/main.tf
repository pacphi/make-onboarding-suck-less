module "managed-zone" {
  source = "git::https://github.com/pacphi/tf4k8s.git//modules/dns/azure"

  base_domain = var.base_domain
  domain_prefix = var.domain_prefix
  resource_group_name = var.resource_group_name
  az_client_id = var.az_client_id
  az_client_secret = var.az_client_secret
  az_subscription_id = var.az_subscription_id
  az_tenant_id = var.az_tenant_id
}

variable "base_domain" {
  description = "The base domain where an NS recordset will be added mirroring a new sub-domain's recordset"
}

variable "domain_prefix" {
  description = "Prefix for a domain (e.g. in lab.cloudmonk.me, 'lab' is the prefix)"
}

variable "resource_group_name" {
  description = "A nrame for a resource group; @see https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#what-is-a-resource-group"
}

variable "az_client_id" {
  description = "Azure Service Principal appId"
  sensitive = true
}

variable "az_client_secret" {
  description = "Azure Service Principal password"
  sensitive = true
}

variable "az_subscription_id" {
  description = "Azure Subscription id"
  sensitive = true
}

variable "az_tenant_id" {
  description = "Azure Service Principal tenant"
  sensitive = true
}

output "zone_subdomain" {
  value = module.managed-zone.zone_subdomain
}
