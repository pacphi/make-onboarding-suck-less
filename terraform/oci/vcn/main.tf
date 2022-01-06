# @see https://registry.terraform.io/modules/oracle-terraform-modules/vcn/oci/latest

module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "3.1.0"

  tenancy_id = var.tenancy_ocid
  user_id = var.user_ocid
  api_fingerprint = var.fingerprint
  api_private_key_path = var.private_key_path
  region = var.region

  compartment_id = var.vcn_compartment_ocid
  vcn_name = var.vcn_name
  vcn_dns_label = var.vcn_dns_label
  vcn_cidrs = [ "${var.vcn_public_subnet_ip_address}/16" ]
}

# Source from https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_security_list

resource "oci_core_security_list" "private-security-list" {

  compartment_id = var.vcn_compartment_ocid
  vcn_id = module.vcn.vcn_id

  display_name = "security-list-for-private-subnet"

  egress_security_rules {
    stateless = false
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol = "all"
  }

  ingress_security_rules = [
    {
      stateless = false
      source = "${var.vcn_public_subnet_ip_address}/16"
      source_type = "CIDR_BLOCK"
      # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
      protocol = "6"
      tcp_options = {
          min = 22
          max = 22
      }
    },
    {
      stateless = false
      source = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1
      protocol = "1"
      # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
      icmp_options = {
        type = 3
        code = 4
      }
    },
    {
      stateless = false
      source = "${var.vcn_public_subnet_ip_address}/16"
      source_type = "CIDR_BLOCK"
      # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1
      protocol = "1"
      # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
      icmp_options = {
        type = 3
      }
    }
  ]
}

resource "oci_core_security_list" "public-security-list" {

  compartment_id = var.vcn_compartment_ocid
  vcn_id = module.vcn.vcn_id

  display_name = "security-list-for-public-subnet"

  egress_security_rules {
    stateless = false
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol = "all"
  }

  ingress_security_rules = [
    {
      stateless = false
      source = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
      protocol = "6"
      tcp_options = {
          min = 22
          max = 22
      }
    },
    {
      stateless = false
      source = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1
      protocol = "1"
      # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
      icmp_options = {
        type = 3
        code = 4
      }
    },
    {
      stateless = false
      source = "${var.vcn_public_subnet_ip_address}/16"
      source_type = "CIDR_BLOCK"
      # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1
      protocol = "1"
      # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
      icmp_options = {
        type = 3
      }
    }
  ]
}


# Source from https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_subnet

resource "oci_core_subnet" "vcn-private-subnet" {

  compartment_id = var.vcn_compartment_ocid
  vcn_id = module.vcn.vcn_id
  cidr_block = "${var.vcn_private_subnet_ip_address}/24"

  # Caution: For the route table id, use module.vcn.nat_route_id.
  # Do not use module.vcn.nat_gateway_id, because it is the OCID for the gateway and not the route table.
  route_table_id = module.vcn.nat_route_id
  security_list_ids = [ oci_core_security_list.private-security-list.id ]
  display_name = "private-subnet"
}

resource "oci_core_subnet" "vcn-public-subnet" {

  compartment_id = var.vcn_compartment_ocid
  vcn_id = module.vcn.vcn_id
  cidr_block = "${var.vcn_public_subnet_ip_address}/24"

  route_table_id = module.vcn.ig_route_id
  security_list_ids = [ oci_core_security_list.public-security-list.id ]
  display_name = "public-subnet"
}


# Source from https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_dhcp_options

resource "oci_core_dhcp_options" "dhcp-options" {

  compartment_id = var.vcn_compartment_ocid
  vcn_id = module.vcn.vcn_id
  #Options for type are either "DomainNameServer" or "SearchDomain"
  options {
    type = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  display_name = "default-dhcp-options"
}