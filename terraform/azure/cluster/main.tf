module "aks" {
  source  = "git::https://github.com/pacphi/tf4k8s.git//modules/cluster/aks"

  aks_resource_group = var.aks_resource_group
  enable_logs = var.enable_logs
  ssh_public_key = var.ssh_public_key
  az_subscription_id = var.az_subscription_id
  az_client_id = var.az_client_id
  az_client_secret = var.az_client_secret
  az_tenant_id = var.az_tenant_id
  aks_region = var.aks_region
  aks_name = var.aks_name
  aks_nodes = var.aks_nodes
  aks_node_type = var.aks_node_type
  aks_pool_name = var.aks_pool_name
  aks_node_disk_size = var.aks_node_disk_size
}

variable "aks_resource_group" {
  description = "Microsoft Azure Resource group name"
}

variable "enable_logs" {
  description = "Enable azure log analtics for container logs"
}

variable "ssh_public_key" {
  description = "Path to your SSH public key (e.g. `~/.ssh/id_rsa.pub`)"
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

variable "aks_region" {
  description = "AKS region (e.g. `West US 2`) -> `az account list-locations --output table`"
}

variable "aks_name" {
  description = "AKS cluster name (e.g. `k8s-aks`)"
}

variable "aks_nodes" {
  description = "AKS Kubernetes worker nodes (e.g. `2`)"
}

variable "aks_node_type" {
  description = "AKS node pool instance type (e.g. `Standard_D1_v2` => 1vCPU, 3.75 GB RAM)"
}

variable "aks_pool_name" {
  description = "AKS agent node pool name (e.g. `k8s-aks-nodepool`)"
}

variable "aks_node_disk_size" {
  description = "AKS node instance disk size in GB (e.g. `30` => minimum: 30GB, maximum: 1024)"
}

output "kubeconfig_contents" {
  value = file(module.aks.kubeconfig_path_aks)
}

output "public_ip_address" {
  value = module.aks.public_ip_address
}

output "public_ip_fqdn" {
  value = module.aks.public_ip_fqdn
}