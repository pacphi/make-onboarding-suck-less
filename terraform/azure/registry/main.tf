module "acr" {
  source = "git::https://github.com/pacphi/tf4k8s.git//modules/registry/acr"

  registry_name = var.registry_name
  location      = var.location
  resource_group_name = var.resource_group_name
  az_subscription_id = var.az_subscription_id
  az_client_id = var.az_client_id
  az_client_secret = var.az_client_secret
  az_tenant_id = var.az_tenant_id
}

variable "registry_name" {
  description = "Specifies the name of the Container Registry.  This name will be updated to append a unique suffix so as not to collide with a pre-existing registry."
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Container Registry.  The resource group must already exist, it is not created."
}

variable "location" {
  description = "Specifies the supported Azure location where the resource exists"
  default = "US West 2"
}

variable "az_subscription_id" {
  description = "Azure Subscription id"
  sensitive = true
}

variable "az_client_id" {
  description = "Azure Service Principal appId"
  sensitive = true
}

variable "az_client_secret" {
  description = "Azure Service Principal password"
  sensitive = true
}

variable "az_tenant_id" {
  description = "Azure Service Principal tenant"
  sensitive = true
}

output "acr_id" {
  description = "The ID of the Container Registry"
  value = module.acr.acr_id
}

output "acr_name" {
  value = module.acr.acr_name
}

output "acr_url" {
  description = "The URL that can be used to log into the container registry"
  value = module.acr.acr_url
}

output "acr_admin_username" {
  description = "The username associated with the Container Registry admin account"
  value = module.acr.acr_admin_username
}

output "acr_admin_password" {
  description = "The password associated with the Container Registry admin account"
  value = module.acr.acr_admin_password
  sensitive = true
}