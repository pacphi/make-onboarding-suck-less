data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "random_string" "suffix" {
  length           = 3
  special          = false
}

resource "oci_core_vcn" "vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.vcn_compartment_ocid
  display_name   = "${var.vcn_name}-${random_string.suffix.result}"
}

resource "oci_core_drg" "drg" {
  compartment_id = var.vcn_compartment_ocid
  display_name   = "drg-${random_string.suffix.result}"
}

resource "oci_core_drg_attachment" "drg_attachment" {
  drg_id       = oci_core_drg.drg.id
  vcn_id       = oci_core_vcn.vcn.id
  display_name = "drg-attachment-${random_string.suffix.result}"
}

resource "oci_core_service_gateway" "service_gateway" {
  compartment_id = var.vcn_compartment_ocid
  display_name   = "service-gw-${random_string.suffix.result}"
  vcn_id         = oci_core_vcn.vcn.id
  services {
    service_id = lookup(data.oci_core_services.all_oci_services.services[0], "id")
  }
}

resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = var.vcn_compartment_ocid
  display_name   = "nat-gw-${random_string.suffix.result}"
  vcn_id         = oci_core_vcn.vcn.id
}

resource "oci_core_route_table" "route_table_via_nat" {
  compartment_id = var.vcn_compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "route-table-via-nat-${random_string.suffix.result}"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gateway.id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.all_oci_services.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.service_gateway.id
  }
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

resource "oci_core_security_list" "oke_security_list" {
  compartment_id = var.vcn_compartment_ocid
  display_name   = "oke-security-list-${random_string.suffix.result}"
  vcn_id         = oci_core_vcn.vcn.id

  egress_security_rules {
    protocol    = "All"
    destination = "0.0.0.0/0"
  }

  /* This entry is necesary for DNS resolving (open UDP traffic). */
  ingress_security_rules {
    protocol = "17"
    source   = var.vcn_cidr
  }
}

resource "oci_core_security_list" "private_k8s_api_endpoint_subnet_security_list" {
  compartment_id = var.vcn_compartment_ocid
  display_name   = "private-k8s-api-endpoint-subnet-security-list-${random_string.suffix.result}"
  vcn_id         = oci_core_vcn.vcn.id

  # egress_security_rules

  egress_security_rules {
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = var.k8s_node_pool_subnet_cidr
  }

  egress_security_rules {
    protocol         = 1
    destination_type = "CIDR_BLOCK"
    destination      = var.k8s_node_pool_subnet_cidr

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "SERVICE_CIDR_BLOCK"
    destination      = lookup(data.oci_core_services.all_oci_services.services[0], "cidr_block")

    tcp_options {
      min = 443
      max = 443
    }
  }

  # ingress_security_rules

  ingress_security_rules {
    protocol = "6"
    source   = var.k8s_node_pool_subnet_cidr

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.k8s_node_pool_subnet_cidr

    tcp_options {
      min = 12250
      max = 12250
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    protocol = 1
    source   = var.k8s_node_pool_subnet_cidr

    icmp_options {
      type = 3
      code = 4
    }
  }

}

resource "oci_core_security_list" "private_k8s_private_worker_nodes_subnet_security_list" {
  compartment_id = var.vcn_compartment_ocid
  display_name   = "private-k8s-private-worker-nodes-subnet-security-list-${random_string.suffix.result}"
  vcn_id         = oci_core_vcn.vcn.id


  # egress_security_rules

  egress_security_rules {
    protocol         = "All"
    destination_type = "CIDR_BLOCK"
    destination      = var.k8s_node_pool_subnet_cidr
  }

  egress_security_rules {
    protocol    = 1
    destination = "0.0.0.0/0"

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "SERVICE_CIDR_BLOCK"
    destination      = lookup(data.oci_core_services.all_oci_services.services[0], "cidr_block")
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = var.k8s_api_endpoint_subnet_cidr

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = var.k8s_api_endpoint_subnet_cidr

    tcp_options {
      min = 12250
      max = 12250
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = "0.0.0.0/0"
  }

  # ingress_security_rules

  ingress_security_rules {
    protocol = "All"
    source   = var.k8s_node_pool_subnet_cidr
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.k8s_api_endpoint_subnet_cidr
  }

  ingress_security_rules {
    protocol = 1
    source   = "0.0.0.0/0"

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 22
      max = 22
    }
  }

}

resource "oci_core_subnet" "k8s_api_endpoint_subnet" {
  cidr_block     = var.k8s_api_endpoint_subnet_cidr
  compartment_id = var.vcn_compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "k8s-api-endpoint-subnet-${random_string.suffix.result}"

  security_list_ids          = [oci_core_vcn.vcn.default_security_list_id, oci_core_security_list.private_k8s_api_endpoint_subnet_security_list.id]
  route_table_id             = oci_core_route_table.route_table_via_nat.id
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "k8s_lb_subnet" {
  cidr_block     = var.k8s_lb_subnet_cidr
  compartment_id = var.vcn_compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "k8s-lb-subnet-${random_string.suffix.result}"

  security_list_ids          = [oci_core_vcn.vcn.default_security_list_id]
  route_table_id             = oci_core_route_table.route_table_via_nat.id
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "k8s_node_pool_subnet" {
  cidr_block     = var.k8s_node_pool_subnet_cidr
  compartment_id = var.vcn_compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "k8s-node-pool-subnet-${random_string.suffix.result}"

  security_list_ids          = [oci_core_vcn.vcn.default_security_list_id, oci_core_security_list.private_k8s_private_worker_nodes_subnet_security_list.id]
  route_table_id             = oci_core_route_table.route_table_via_nat.id
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "bastion_subnet" {
  cidr_block     = var.bastion_subnet_cidr
  compartment_id = var.vcn_compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "bastion-subnet-${random_string.suffix.result}"

  security_list_ids = [oci_core_vcn.vcn.default_security_list_id, oci_core_security_list.oke_security_list.id]
  route_table_id    = oci_core_route_table.route_table_via_igw.id
}