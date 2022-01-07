# Outputs for the vcn module

output "vcn_id" {
  description = "OCID of the VCN that is created"
  value = module.vcn.vcn_id
}

output "id-for-route-table-that-includes-the-internet-gateway" {
  description = "OCID of the internet-route table. This route table has an Internet Gateway to be used for public subnets"
  value = module.vcn.ig_route_id
}

output "nat-gateway-id" {
  description = "OCID for NAT gateway"
  value = module.vcn.nat_gateway_id
}

output "internet-gateway-id" {
  description = "OCID for Internet gateway"
  value = module.vcn.internet_gateway_id
}

output "id-for-for-route-table-that-includes-the-nat-gateway" {
  description = "OCID of the nat-route table - This route table has a NAT Gateway to be used for private subnets. This route table also has a service gateway."
  value = module.vcn.nat_route_id
}


# Outputs for private subnet

output "private-subnet-name" {
  value = oci_core_subnet.vcn-private-subnet.display_name
}

output "private-subnet-ocid" {
  value = oci_core_subnet.vcn-private-subnet.id
}


# Outputs for public subnet

output "public-subnet-name" {
  value = oci_core_subnet.vcn-public-subnet.display_name
}

output "public-subnet-ocid" {
  value = oci_core_subnet.vcn-public-subnet.id
}


# Outputs for DHCP Options

output "dhcp-options-name" {
  value = oci_core_dhcp_options.dhcp-options.display_name
}

output "dhcp-options-ocid" {
  value = oci_core_dhcp_options.dhcp-options.id
}