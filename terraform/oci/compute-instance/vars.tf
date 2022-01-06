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

variable "ssh_public_key_path" {
  type = string
  description = "The path to a public key (.pem) file that will be installed on the compute instance and used for secure shell access with a private key pair."
  default = "~/.oci/oci_api_public_key.pem"
}

variable "compute_instance_compartment_ocid" {
  type = string
  description = "Oracle-assigned unique ID for compartment where compute instance will reside (available in every region that your tenancy is subscribed to)"
}

variable "compute_instance_name" {
  type = string
  description = "Friendly name given to the compute instance"
}

variable "compute_instance_shape" {
  type = string
  description = "A shape is a template that determines the number of OCPUs, amount of memory, and other resources that are allocated to a compute instance. Compute shapes are available with AMD processors, Intel processors, and Arm-based processors.  See https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm."
  default = "VM.Standard2.2"
}

variable "compute_instance_source_image_ocid" {
  type = string
  description = "Oracle-assigned unique ID for a pre-existing compute instance image.  To list available images, see https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/compute/image/list.html."
}

variable "compute_instance_subnet_ocid" {
  type = string
  description = "Oracle-assigned unique ID for a pre-existing subnet"
}