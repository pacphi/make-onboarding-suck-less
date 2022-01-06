variable "tenancy_ocid" {
  type = string
  description = "Oracle-assigned unique ID for Tenancy"
}

variable "user_ocid" {
  type = string
  description = "Oracle-assigned unique ID for a User account"
}

variable "private_key_path" {
  type = string
  description = "The path to the private key (.pem) file that corresponds to the public key you uploaded for the User account"
  default = "~/.oci/oci_api_key.pem"
}

variable "fingerprint" {
  type = string
  description = "Fingerprint of the public key (.pem) file"
}

variable "region" {
  type = string
  description = "Oracle Cloud data center location (e.g., us-phoenix-1)"
}

variable "vcn_compartment_ocid" {
  type = string
  description = "Oracle-assigned unique ID for compartment where virtual cloud network will reside"
}

variable "vcn_name" {
  type = string
  description = "User-friendly name of to use for the VCN to be appended to the label_prefix"
}

variable "vcn_dns_label" {
  type = string
  description = "A DNS label for the VCN, used in conjunction with the VNIC's hostname and subnet's DNS label to form a fully qualified domain name (FQDN) for each VNIC within this subnet"
}

variable "vcn_public_subnet_ip_address" {
  type = string
  default = "10.0.0.0"
}

variable "vcn_private_subnet_ip_address" {
  type = string
  default = "10.0.1.0"
}
