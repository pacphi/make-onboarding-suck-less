output "vcn-ocid" {
  description = "OCID of the VCN that is created"
  value = oci_core_vcn.vcn.id
}

output "nat-gateway-ocid" {
  description = "OCID for NAT gateway"
  value = oci_core_nat_gateway.nat_gateway.id
}

output "internet-gateway-id" {
  description = "OCID for Internet gateway"
  value = oci_core_internet_gateway.igw.id
}

output "bastion-subnet-ocid" {
  description = "OCID for Bastion Host subnet"
  value = oci_core_subnet.bastion_subnet.id
}

output "k8s-api-enpoint-subnet-ocid" {
  description = "OCID for Kubernetes API endpoint subnet"
  value = oci_core_subnet.k8s_api_endpoint_subnet.id
}

output "k8s-lb-subnet-ocid" {
  description = "OCID for Kubernetes LB subnet"
  value = oci_core_subnet.k8s_lb_subnet.id
}

output "k8s-node-pool-subnet-ocid" {
  description = "OCID for Kubernetes Node Pool subnet"
  value = oci_core_subnet.k8s_node_pool_subnet.id
}