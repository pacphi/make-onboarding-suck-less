module "eks" {
  source  = "git::https://github.com/pacphi/tf4k8s.git//modules/cluster/eks"

  eks_name = var.eks_name
  desired_nodes = var.desired_nodes
  min_nodes = var.min_nodes
  max_nodes = var.max_nodes
  kubernetes_version = var.kubernetes_version
  region = var.region
  availability_zones = var.availability_zones
  ssh_key_name = var.ssh_key_name
  node_pool_instance_type = var.node_pool_instance_type
  tags = var.tags
}

variable "eks_name" {}

variable "desired_nodes" {
  description = "Desired number of worker nodes"
}

variable "min_nodes" {
  description = "Minimum number of worker nodes"
}

variable "max_nodes" {
  description = "Maximum number of worker nodes"
}

variable "kubernetes_version" {
  default = "1.21.2-1-amazon2"
}

variable "region" {
  default = "us-west-2"
}

variable "availability_zones" {
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "ssh_key_name" {}

variable "node_pool_instance_type" {
  default = "t3a.large"
}

variable "tags" {
  default = {}
}

output "ssh_key_name" {
  description = "Name of SSH key used for bastion host and cluster worker nodes"
  value = module.eks.ssh_key_name
}

output "ssh_private_key_filename" {
  description = "Private Key Filename"
  value = module.eks.ssh_private_key_filename
}

output "ssh_public_key_filename" {
  description = "Public Key Filename"
  value = module.eks.ssh_public_key_filename
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value = module.eks.eks_cluster_name
}

output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value = module.eks.eks_cluster_arn
}

output "eks_region" {
  description = "The AWS region within which the EKS cluster is running"
  value = module.eks.eks_region
}

output "kubeconfig_contents" {
  value = file(module.eks.kubeconfig_path_eks)
}
