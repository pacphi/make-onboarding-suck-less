# @see https://registry.terraform.io/modules/oracle-terraform-modules/vcn/oci/latest

module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "3.1.0"

  region = var.region

  compartment_id = var.vcn_compartment_ocid
  vcn_name = var.vcn_name
  vcn_dns_label = var.vcn_dns_label
  vcn_cidrs = [ "${var.vcn_public_subnet_ip_address}/16" ]

  create_internet_gateway = true
  create_nat_gateway = true
  create_service_gateway = false
}

# Source from https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_security_list

resource "oci_core_security_list" "private-outbound-all" {

  compartment_id = var.vcn_compartment_ocid
  vcn_id = module.vcn.vcn_id

  display_name = "private-outbound-all"

  egress_security_rules {
    stateless = false
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol = "all"
  }
}

resource "oci_core_security_list" "private-inbound-ssh" {

  compartment_id = var.vcn_compartment_ocid
  vcn_id = module.vcn.vcn_id

  display_name = "private-inbound-ssh"

  ingress_security_rules {
    stateless = false
    source = "${var.vcn_public_subnet_ip_address}/16"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_security_list" "private-inbound-icmp-0" {

  compartment_id = var.vcn_compartment_ocid
  vcn_id = module.vcn.vcn_id

  display_name = "private-inbound-icmp-0"

  ingress_security_rules {
    stateless = false
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1
    protocol = "1"
    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
      code = 4
    }
  }
}

resource "oci_core_security_list" "private-inbound-icmp-1" {

  compartment_id = var.vcn_compartment_ocid
  vcn_id = module.vcn.vcn_id

  display_name = "private-inbound-icmp-1"

  ingress_security_rules {
    stateless = false
    source = "${var.vcn_public_subnet_ip_address}/16"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1
    protocol = "1"
    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
    }
  }
}

resource "oci_core_security_list" "public-outbound-all" {

  compartment_id = var.vcn_compartment_ocid
  vcn_id = module.vcn.vcn_id

  display_name = "public-outbound-all"

  egress_security_rules {
    stateless = false
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol = "all"
  }
}

resource "oci_core_security_list" "public-inbound-ssh" {

  compartment_id = var.vcn_compartment_ocid
  vcn_id = module.vcn.vcn_id

  display_name = "public-inbound-ssh"

  ingress_security_rules {
      stateless = false
      source = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
      protocol = "6"
      tcp_options {
        min = 22
        max = 22
      }
  }
}

resource "oci_core_security_list" "public-inbound-icmp-0" {

  compartment_id = var.vcn_compartment_ocid
  vcn_id = module.vcn.vcn_id

  display_name = "public-inbound-icmp-0"

  ingress_security_rules {
    stateless = false
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1
    protocol = "1"
    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
      code = 4
    }
  }
}

resource "oci_core_security_list" "public-inbound-icmp-1" {

  compartment_id = var.vcn_compartment_ocid
  vcn_id = module.vcn.vcn_id

  display_name = "public-inbound-icmp-1"

  ingress_security_rules {
    stateless = false
    source = "${var.vcn_public_subnet_ip_address}/16"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1
    protocol = "1"
    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
    }
  }
}


# Source from https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_subnet

resource "oci_core_subnet" "vcn-private-subnet" {

  compartment_id = var.vcn_compartment_ocid
  vcn_id = module.vcn.vcn_id
  cidr_block = "${var.vcn_private_subnet_ip_address}/24"

  # Caution: For the route table id, use module.vcn.nat_route_id.
  # Do not use module.vcn.nat_gateway_id, because it is the OCID for the gateway and not the route table.
  route_table_id = module.vcn.nat_route_id
  security_list_ids = [
    oci_core_security_list.private-outbound-all.id,
    oci_core_security_list.private-inbound-ssh.id,
    oci_core_security_list.private-inbound-icmp-0.id,
    oci_core_security_list.private-inbound-icmp-0.id
  ]
  display_name = "private-subnet"
}

resource "oci_core_subnet" "vcn-public-subnet" {

  compartment_id = var.vcn_compartment_ocid
  vcn_id = module.vcn.vcn_id
  cidr_block = "${var.vcn_public_subnet_ip_address}/24"

  route_table_id = module.vcn.ig_route_id
  security_list_ids = [
    oci_core_security_list.public-outbound-all.id,
    oci_core_security_list.public-inbound-ssh.id,
    oci_core_security_list.public-inbound-icmp-0.id,
    oci_core_security_list.public-inbound-icmp-0.id
  ]
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