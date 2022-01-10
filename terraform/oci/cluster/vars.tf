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

variable "vcn_ocid" {
  type = string
  description = "Oracle-assigned unique ID for a virtual cloud network"
}

variable "compartment_ocid" {
  type = string
  description = "Oracle-assigned unique ID for a Compartment"
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

variable "k8s_version" {
  type = string
  description = "A support Kubernetes cluster version (e.g., v1.20.11).  See https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengaboutk8sversions.htm."
  default = "v1.21.5"
}

variable "k8s_api_endpoint_subnet_ocid" {
  type = string
  description = "OCID of the Kubernetes API endpoint subnet"
}

variable "k8s_lb_subnet_ocid" {
  type = string
  description = "OCID of the Kubernetes Load-balancer subnet"
}

variable "k8s_net_pods_cidr" {
  type = string
  default = "10.1.0.0/16"
}

variable "k8s_net_services_cidr" {
  type = string
  default = "10.2.0.0/16"
}

variable "cluster_name" {
  type = string
  description = "The name ascribed to the Kubernetes cluster"
}

variable "node_pool_size" {
  default = 6
}
