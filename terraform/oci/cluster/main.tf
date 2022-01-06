# Source from https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/containerengine_cluster

resource "oci_containerengine_cluster" "oke-cluster" {
  compartment_id = var.compartment_ocid
  kubernetes_version = var.k8s_version
  name = var.cluster_name
  vcn_id = var.vcn_ocid

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled = false
    }
    kubernetes_network_config {
      pods_cidr = "10.244.0.0/16"
      services_cidr = "10.96.0.0/16"
    }
    service_lb_subnet_ids = [ var.vcn_public_subnet_ocid ]
  }
}


# Source from https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/containerengine_node_pool

resource "oci_containerengine_node_pool" "oke-node-pool" {

  cluster_id = oci_containerengine_cluster.oke-cluster.id
  compartment_id = var.compartment_ocid
  kubernetes_version = var.k8s_version
  name = "pool1"
  node_config_details {
    placement_configs = [
      {
        availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
        subnet_id = var.vcn_private_subnet_ocid
      },
      {
        availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
        subnet_id = var.vcn_private_subnet_ocid
      },
      {
        availability_domain = data.oci_identity_availability_domains.ads.availability_domains[2].name
        subnet_id = var.vcn_private_subnet_ocid
      }
    ]
    size = 3
  }
  node_shape = var.compute_instance_shape

  # Find image OCID for your region
  node_source_details {
    image_id = var.compute_instance_source_image_ocid
    source_type = "image"
  }

  # Optional
  initial_node_labels {
    key = "name"
    value = "pool1"
  }
}
