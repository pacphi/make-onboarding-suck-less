
# Source from https://registry.terraform.io/modules/oracle-terraform-modules/oke/oci/latest?tab=outputs

output "bastion_public_ip" {
  description = "Public IP address of Bastion host"
  value = module.oke.bastion_public_ip
}

output "bastion_service_instance_ocid" {
  description = "OCID for the Bastion service"
  value = module.oke.bastion_service_instance_id
}

output "cluster_ocid" {
  description = "OCID for the Kubernetes cluster"
  value = module.oke.cluster_id
}

output "ig_route_ocid" {
  description = "OCID for the route table of the VCN Internet Gateway"
  value = module.oke.ig_route_id
}

output "internal_lb_nsg_ocid" {
  description = "OCID of default NSG that can be associated with the internal load balancer"
  value = module.oke.int_lb_nsg
}

output "kubeconfig" {
  description = "Convenient command to set KUBECONFIG environment variable before running kubectl locally"
  value = module.oke.kubeconfig
}

output "nat_route_ocid" {
  description = "OCID of route table to NAT Gateway attached to VCN"
  value = module.oke.nat_route_id
}

output nodepool_ocids {
  description = "Map of Nodepool names and OCIDs"
  value = module.oke.nodepool_ids
}

output operator_private_ip {
  description = "Private IP address of Operator host"
  value = module.oke.operator_private_ip
}

output "public_lb_nsg_ocid" {
  description = "OCID of default NSG that can be associated with the internal load balancer"
  value = module.oke.pub_lb_nsg
}

output "ssh_to_bastion" {
  description = "Convenient command to SSH to the Bastion host"
  value = module.oke.ssh_to_bastion
}

output "ssh_to_operator" {
  description = "Convenient command to SSH to the Operator host"
  value = module.oke.ssh_to_operator
}

output "subnet_ocids" {
  description = "Map of subnet OCIDs (worker, int_lb, pub_lb) used by OKE"
  value = module.oke.subnet_ids
}

output "vcn_ocid" {
  description = "OCID of VCN where OKE is created. Use this VCN OCID to add more resources."
  value = module.oke.vcn_id
}
