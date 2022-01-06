# Source from https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/artifacts_container_repository

resource "oci_artifacts_container_repository" "cr" {
  compartment_id = var.compartment_ocid
  display_name = var.container_repository_display_name

  is_immutable = var.container_repository_is_immutable
  is_public = var.container_repository_is_public
}
