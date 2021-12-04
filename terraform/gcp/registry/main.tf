module "gcr" {
  source        = "git::https://github.com/pacphi/tf4k8s.git//modules/registry/gcr"

  project       = var.project
  location      = var.location
  credentials   = var.gcp_service_account_credentials

}

variable "project" {
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  sensitive = true
}

variable "location" {
  description = "The location of the registry. One of [ asia, eu, us ] or not specified."
  default = "us"
}

variable "gcp_service_account_credentials" {
  description = "Path to service account credentials file in JSON format"
}

output "gcr_bucket_id" {
  description = "The name of the bucket that supports the Container Registry"
  value = module.gcr.gcr_bucket_id
}

output "gcr_repository_url" {
  description = "The URL at which the repository can be accessed"
  value = module.gcr.gcr_repository_url
}
