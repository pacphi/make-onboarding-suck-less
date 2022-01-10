# Source from https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/artifacts_container_repository

resource "random_string" "suffix" {
  length           = 3
  special          = false
}

resource "oci_artifacts_container_repository" "cr" {
  compartment_id = var.compartment_ocid
  display_name = "${var.display_name}-${random_string.suffix.result}"

  is_immutable = var.is_immutable
  is_public = var.is_public
}
