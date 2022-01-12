resource "oci_identity_compartment" "tf-compartment" {
  compartment_id = var.tenancy_ocid
  description = var.compartment_description
  name = var.compartment_name
}