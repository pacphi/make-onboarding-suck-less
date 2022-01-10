data "oci_core_images" "i" {
  compartment_id           = var.compartment_ocid
  operating_system         = local.instance_os
  operating_system_version = local.os_version
  shape                    = var.compute_instance_shape

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

# Source from https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/containerengine_cluster

resource "oci_containerengine_cluster" "oke-cluster" {
  compartment_id = var.compartment_ocid
  kubernetes_version = var.k8s_version
  name = var.cluster_name
  vcn_id = var.vcn_ocid

  endpoint_config {
    is_public_ip_enabled = false
    subnet_id            = var.k8s_api_endpoint_subnet_ocid
  }
  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled = false
    }
    kubernetes_network_config {
      pods_cidr = var.k8s_net_pods_cidr
      services_cidr = var.k8s_net_services_cidr
    }
    service_lb_subnet_ids = [ var.k8s_lb_subnet_ocid ]
  }
}


# Source from https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/containerengine_node_pool

resource "oci_containerengine_node_pool" "oke-node-pool" {

  cluster_id = oci_containerengine_cluster.oke-cluster.id
  compartment_id = var.compartment_ocid
  kubernetes_version = var.k8s_version
  name = "${var.cluster_name}-pool"
  node_shape = var.compute_instance_shape
  node_config_details {
    placement_configs {
        availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
        subnet_id = var.k8s_node_pool_subnet_ocid
    }

    placement_configs {
        availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
        subnet_id = var.k8s_node_pool_subnet_ocid
    }

    placement_configs {
        availability_domain = data.oci_identity_availability_domains.ads.availability_domains[2].name
        subnet_id = var.k8s_node_pool_subnet_ocid
    }

    size = var.node_pool_size
  }
  dynamic "node_shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.compute_instance_memory
      ocpus         = var.compute_instance_ocpus
    }
  }

  node_source_details {
    image_id = data.oci_core_images.i.images[0].id
    source_type = "image"
  }

  initial_node_labels {
    key = "name"
    value = "${var.cluster_name}-pool"
  }

  ssh_public_key = file(var.ssh_public_key_path)
}
