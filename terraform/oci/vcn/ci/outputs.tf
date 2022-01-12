output "vcn-ocid" {
  description = "OCID of the VCN"
  value = oci_core_vcn.vcn.id
}

output "public-subnet-ocid" {
  description = "OCID of the public subnet within the VCN"
  value = oci_core_subnet.public_subnet.id
}
