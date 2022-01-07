# Outputs for compartment

output "compartment-name" {
  value = oci_identity_compartment.tf-compartment.name
}

output "compartment-ocid" {
  value = oci_identity_compartment.tf-compartment.id
}