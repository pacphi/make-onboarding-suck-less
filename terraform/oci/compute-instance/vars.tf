locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard3.Flex",
    "VM.Optimized3.Flex",
    "VM.Standard.A1.Flex"
  ]
  is_flexible_compute_instance_shape = contains(local.compute_flexible_shapes, var.compute_instance_shape)
  instance_os = "Canonical Ubuntu"
  os_version = "20.04"
}

variable "tenancy_ocid" {
  type = string
  description = "Oracle-assigned unique ID for Tenancy"
}

variable "user_ocid" {
  type = string
  description = "Oracle-assigned unique ID for a User account"
}

variable "oci_private_key_path" {
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
  description = "The path to a public key (RSA format) file that will be installed on the compute instance and used for secure shell access with a private key pair."
  default = "~/.ssh/id_rsa.pub"
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
  default = "VM.Standard.E4.Flex"
}

variable "compute_instance_memory" {
  description = "Amount of RAM allocated to flexible compute instance"
  default = 16
}

variable "compute_instance_ocpus" {
  description = "# of CPUs allocated to flexible compute instance"
  default = 2
}

variable "compute_instance_subnet_ocid" {
  type = string
  description = "Oracle-assigned unique ID for a pre-existing subnet"
}

variable "source_image_ocid" {
  type = string
  description = "Oracle-assigned unique ID for a source image.  Could be a custom image or a supported OS image."
  default = ""
}