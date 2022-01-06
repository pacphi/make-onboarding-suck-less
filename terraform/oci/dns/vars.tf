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

variable "compartment_ocid" {
  description = "Oracle-assigned unique ID for Compartment this resource will belong to"
}

variable "root_zone_name" {
  description = "The name of an existing Oracle Cloud zone; it'll have an NS record added to it referencing the name servers of a new zone"
}

variable "dns_prefix" {
  description = "Prefix used to create a new domain (e.g., <dns_prefix>.<base-domain>)"
}
