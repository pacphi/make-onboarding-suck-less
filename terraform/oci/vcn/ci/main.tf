resource "random_string" "suffix" {
  length           = 3
  special          = false
}

resource "oci_core_vcn" "vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.vcn_compartment_ocid
  display_name   = "${var.vcn_name}-${random_string.suffix.result}"
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.vcn_compartment_ocid
  display_name   = "igw-${random_string.suffix.result}"
  vcn_id         = oci_core_vcn.vcn.id
}

resource "oci_core_route_table" "route_table_via_igw" {
  compartment_id = var.vcn_compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "route-table-via-igw-${random_string.suffix.result}"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}


resource "oci_core_subnet" "public_subnet" {
  cidr_block     = var.public_subnet_cidr
  compartment_id = var.vcn_compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "public-subnet-${random_string.suffix.result}"

  security_list_ids = [oci_core_vcn.vcn.default_security_list_id,]
  route_table_id    = oci_core_route_table.route_table_via_igw.id
}