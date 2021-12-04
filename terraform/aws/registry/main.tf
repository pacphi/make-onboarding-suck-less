module "ecr" {
  source  = "git::https://github.com/pacphi/tf4k8s.git//modules/registry/ecr"

  registry_name = var.registry_name
  region = var.region
}

variable "registry_name" {
  description = "Specifies the name of the Container Registry.  This name will be updated to append a unique suffix so as not to collide with a pre-existing registry."
}

variable "region" {
  default = "us-west-2"
  description = "A valid AWS region (e.g., us-east-1).  See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-regions."
}

output "ecr_admin_username" {
  description = "The username associated with the Container Registry admin account."
  value = module.ecr.ecr_admin_username
}

output "ecr_admin_password" {
  description = "The password associated with the Container Registry admin account."
  value = module.ecr.ecr_admin_password
  sensitive = true
}

output "ecr_endpoint" {
  description = "The URL that can be used to log into the container image registry."
  value = module.ecr.ecr_endpoint
}

output "ecr_repository_url" {
  description = "The URL of the container image repository (in the form {aws_account_id}.dkr.ecr.{region}.amazonaws.com/{repository-name})."
  value = module.ecr.ecr_repository_url
}