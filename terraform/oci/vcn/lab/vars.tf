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
  description = "Friendly name for the VCN"
  default = "vcn"
}


variable "vcn_cidr" {
  type = string
  description = "CIDR block for the VCN"
  default = "10.0.0.0/16"
}

variable "bastion_subnet_cidr" {
  type = string
  description = "CIDR block for the Bastion Host subnet"
  default = "10.0.1.0/24"
}

variable "k8s_node_pool_subnet_cidr" {
  type = string
  description = "CIDR block for the Kubernetes Node Pool subnet"
  default = "10.0.4.0/24"
}

variable "k8s_api_endpoint_subnet_cidr" {
  type = string
  description = "CIDR block for the Kubernetes API endpoint subnet"
  default = "10.0.2.0/24"
}

variable "k8s_lb_subnet_cidr" {
  type = string
  description = "CIDR block for the Kubernetes Load-balancer subnet"
  default = "10.0.3.0/24"
}