# Outputs for k8s cluster

output "cluster-name" {
  value = oci_containerengine_cluster.oke-cluster.name
}

output "cluster-ocid" {
  value = oci_containerengine_cluster.oke-cluster.id
}

output "endpoint_config" {
  value = oci_containerengine_cluster.oke-cluster.endpoint_config
}

output "endpoints" {
  value = oci_containerengine_cluster.oke-cluster.endpoints
}

output "cluster-kubernetes-version" {
  value = oci_containerengine_cluster.oke-cluster.kubernetes_version
}

output "available_kubernetes_upgrades"{
  value = oci_containerengine_cluster.oke-cluster.available_kubernetes_upgrades
}

output "cluster-state" {
  value = oci_containerengine_cluster.oke-cluster.state
}

output "metadata" {
  value = oci_containerengine_cluster.oke-cluster.metadata
}


# Outputs for k8s node pool

output "node-pool-name" {
  value = oci_containerengine_node_pool.oke-node-pool.name
}

output "node-pool-ocid" {
  value = oci_containerengine_node_pool.oke-node-pool.id
}

output "node-pool-kubernetes-version" {
  value = oci_containerengine_node_pool.oke-node-pool.kubernetes_version
}

output "node-size" {
  value = oci_containerengine_node_pool.oke-node-pool.node_config_details[0].size
}

output "node-shape" {
  value = oci_containerengine_node_pool.oke-node-pool.node_shape
}