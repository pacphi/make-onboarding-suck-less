
output "billable_size_in_gbs" {
  description = "Total storage size in GBs that will be charged"
  value = oci_artifacts_container_repository.cr.billable_size_in_gbs
}

output "compartment_id" {
  description = "The OCID of the compartment in which the container repository exists"
  value = oci_artifacts_container_repository.cr.compartment_id
}

output "created_by" {
  description = "The id of the user or principal that created the resource"
  value = oci_artifacts_container_repository.cr.created_by
}

output "time_created" {
  description = "An RFC 3339 timestamp indicating when the repository was created"
  value = oci_artifacts_container_repository.cr.time_created
}

output "id" {
  description = "The OCID of the container repository"
  value = oci_artifacts_container_repository.cr.id
}

output "image_count" {
  description = "Total number of images"
  value = oci_artifacts_container_repository.cr.image_count
}

output "layer_count" {
  description = "Total number of layers"
  value = oci_artifacts_container_repository.cr.layer_count
}

output "current_state" {
  description = "The current state of the container repository"
  value = oci_artifacts_container_repository.cr.state
}

output "time_last_pushed" {
  description = "An RFC 3339 timestamp indicating when an image was last pushed to the repository"
  value = oci_artifacts_container_repository.cr.time_last_pushed
}
