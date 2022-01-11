
resource "random_string" "suffix" {
  length = 3
  special = false
}

module "oke" {
  source = "oracle-terraform-modules/oke/oci"
  version = "4.1.0"

  # Source from https://github.com/oracle-terraform-modules/terraform-oci-oke/blob/main/docs/terraformoptions.adoc
  # Also see https://registry.terraform.io/modules/oracle-terraform-modules/oke/oci/latest?tab=inputs

  # OCI Provider parameters
  compartment_id = var.compartment_ocid
  tenancy_id = var.tenancy_ocid
  user_id = var.user_ocid
  api_fingerprint = var.api_fingerprint
  api_private_key_path = var.api_private_key_path
  home_region = var.home_region
  region = var.region

  # SSH Keys
  ssh_private_key_path = var.ssh_private_key_path
  ssh_public_key_path = var.ssh_public_key_path

  # A string to be prepended to the name of resources created
  label_prefix = var.label_prefix

  # Networking
  vcn_name = "oke-vcn-${random_string.suffix.result}"
  vcn_dns_label = "oke-vcn-${random_string.suffix.result}"
  create_drg = false
  drg_display_name = "drg-${random_string.suffix.result}"
  enable_waf = var.enable_waf
  internet_gateway_route_rules = var.internet_gateway_route_rules
  local_peering_gateways = var.local_peering_gateways
  lockdown_default_seclist = var.lockdown_default_seclist
  nat_gateway_route_rules = var.nat_gateway_route_rules
  nat_gateway_public_ip_id = var.nat_gateway_public_ip_id
  subnets = var.subnets
  vcn_cidrs = var.vcn_cidrs

  # Bastion Host
  create_bastion_host = var.create_bastion_host
  bastion_access = var.bastion_access
  bastion_image_id = var.bastion_image_id
  bastion_os_version = var.bastion_os_version
  bastion_shape = var.bastion_shape
  bastion_state = var.bastion_state
  bastion_timezone = var.bastion_timezone
  bastion_type = var.bastion_type
  upgrade_bastion = var.upgrade_bastion
  enable_bastion_notification = var.enable_bastion_notification
  bastion_notification_endpoint = var.bastion_notification_endpoint
  bastion_notification_protocol = var.bastion_notification_protocol
  bastion_notification_topic = var.bastion_notification_topic

  # Bastion Service
  create_bastion_service = var.create_bastion_service
  bastion_service_access = var.bastion_service_access
  bastion_service_name = "bastion-service-${random_string.suffix.result}"
  bastion_service_target_subnet = var.bastion_service_target_subnet

  # Operator Host
  create_operator = var.create_operator
  operator_image_id = var.operator_image_id
  operator_nsg_ids = var.operator_nsg_ids
  operator_os_version = var.operator_os_version
  operator_shape = var.operator_shape
  operator_state = var.operator_state
  operator_timezone = var.operator_timezone
  operator_type = var.operator_type
  upgrade_operator = var.upgrade_operator
  enable_operator_notification = var.enable_operator_notification
  operator_notification_endpoint = var.operator_notification_endpoint
  operator_notification_protocol = var.operator_notification_protocol
  operator_notification_topic = var.operator_notification_topic

  # Availability Domain
  availability_domains = var.availability_domains

  # Tagging
  freeform_tags = var.freeform_tags

  # OKE
  admission_controller_options = var.admission_controller_options
  allow_node_port_access = var.allow_node_port_access
  allow_worker_internet_access = var.allow_worker_internet_access
  allow_worker_ssh_access = var.allow_worker_ssh_access
  cluster_name = "oke-${random_string.suffix.result}"
  control_plane_type = var.control_plane_type
  control_plane_allowed_cidrs = var.control_plane_allowed_cidrs
  dashboard_enabled = var.dashboard_enabled
  kubernetes_version = var.kubernetes_version
  pods_cidr = var.pods_cidr
  services_cidr = var.services_cidr

  # KMS Integration
  use_encryption = var.use_encryption
  kms_key_id = var.kms_key_id
  use_signed_images = var.use_signed_images
  image_signing_keys = var.image_signing_keys

  # Node Pools
  check_node_active = var.check_node_active
  node_pools = var.node_pools
  node_pool_image_id = var.node_pool_image_id
  node_pool_os = var.node_pool_os
  node_pool_os_version = var.node_pool_os_version
  worker_nsgs = var.worker_nsgs
  worker_type = var.worker_type

  # Upgrade cluster
  upgrade_nodepool = var.upgrade_nodepool
  node_pools_to_drain = var.node_pools_to_drain
  nodepool_upgrade_method = var.nodepool_upgrade_method
  node_pool_name_prefix = var.node_pool_name_prefix

  # OKE Load Balancers
  load_balancers = var.load_balancers
  preferred_load_balancer = var.preferred_load_balancer
  internal_lb_allowed_cidrs = var.internal_lb_allowed_cidrs
  internal_lb_allowed_ports = var.internal_lb_allowed_ports
  public_lb_allowed_cidrs = var.public_lb_allowed_cidrs
  public_lb_allowed_ports = var.public_lb_allowed_ports

  # OCIR
  email_address = var.email_address
  secret_id = var.secret_id
  secret_name = var.secret_name
  secret_namespace = var.secret_namespace
  username = var.username

  # Calico
  enable_calico = var.enable_calico
  calico_version = var.calico_version

  # K8s Metric Server
  enable_metric_server = var.enable_metric_server
  vpa = var.vpa
  vpa_version = var.vpa_version

  # Gatekeeper
  enable_gatekeeper = var.enable_gatekeeper
  gatekeeeper_version = var.gatekeeeper_version

  # Service Account
  create_service_account = var.create_service_account
  service_account_name = var.service_account_name
  service_account_namespace = var.service_account_namespace
  service_account_cluster_role_binding = var.service_account_cluster_role_binding

  providers = {
    oci.home = oci.home
  }
}

# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# OCI Provider parameters
variable "api_fingerprint" {
  default     = ""
  description = "Fingerprint of the API private key to use with OCI API."
  type        = string
}

variable "api_private_key" {
  default     = ""
  description = "The contents of the private key file to use with OCI API. This takes precedence over private_key_path if both are specified in the provider."
  sensitive   = true
  type        = string
}

variable "api_private_key_password" {
  default     = ""
  description = "The corresponding private key password to use with the api private key if it is encrypted."
  sensitive   = true
  type        = string
}

variable "api_private_key_path" {
  default     = ""
  description = "The path to the OCI API private key."
  type        = string
}

variable "home_region" {
  # List of regions: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/regions.htm#ServiceAvailabilityAcrossRegions
  description = "The tenancy's home region. Required to perform identity operations."
  type        = string
}

variable "region" {
  # List of regions: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/regions.htm#ServiceAvailabilityAcrossRegions
  description = "The OCI region where OKE resources will be created."
  type        = string
}

variable "tenancy_ocid" {
  description = "The tenancy id of the OCI Cloud Account in which to create the resources."
  type        = string
}

variable "user_ocid" {
  description = "The id of the user that terraform will use to create the resources."
  type        = string
  default     = ""
}

# General OCI parameters
variable "compartment_ocid" {
  description = "The compartment id where to create all resources."
  type        = string
}

variable "label_prefix" {
  default     = "none"
  description = "A string that will be prepended to all resources."
  type        = string
}

# ssh keys
variable "ssh_private_key" {
  default     = ""
  description = "The contents of the private ssh key file."
  sensitive   = true
  type        = string
}

variable "ssh_private_key_path" {
  default     = "none"
  description = "The path to ssh private key."
  type        = string
}

variable "ssh_public_key" {
  default     = ""
  description = "The contents of the ssh public key."
  type        = string
}

variable "ssh_public_key_path" {
  default     = "none"
  description = "The path to ssh public key."
  type        = string
}

# vcn parameters
variable "create_drg" {
  description = "whether to create Dynamic Routing Gateway. If set to true, creates a Dynamic Routing Gateway and attach it to the VCN."
  type        = bool
  default     = false
}

variable "internet_gateway_route_rules" {
  description = "(Updatable) List of routing rules to add to Internet Gateway Route Table"
  type        = list(map(string))
  default     = null
}

variable "local_peering_gateways" {
  description = "Map of Local Peering Gateways to attach to the VCN."
  type        = map(any)
  default     = null
}

variable "lockdown_default_seclist" {
  description = "whether to remove all default security rules from the VCN Default Security List"
  default     = true
  type        = bool
}

variable "nat_gateway_route_rules" {
  description = "(Updatable) List of routing rules to add to NAT Gateway Route Table"
  type        = list(map(string))
  default     = null
}

variable "nat_gateway_public_ip_id" {
  description = "OCID of reserved IP address for NAT gateway. The reserved public IP address needs to be manually created."
  default     = "none"
  type        = string
}

variable "subnets" {
  description = "parameters to cidrsubnet function to calculate subnet masks within the VCN."
  default = {
    bastion  = { netnum = 0, newbits = 13 }
    operator = { netnum = 1, newbits = 13 }
    cp       = { netnum = 2, newbits = 13 }
    int_lb   = { netnum = 16, newbits = 11 }
    pub_lb   = { netnum = 17, newbits = 11 }
    workers  = { netnum = 1, newbits = 2 }
  }
  type = map(any)
}

variable "vcn_cidrs" {
  default     = ["10.0.0.0/16"]
  description = "The list of IPv4 CIDR blocks the VCN will use."
  type        = list(string)
}

# bastion host parameters
variable "create_bastion_host" {
  default     = true
  description = "Whether to create a bastion host."
  type        = bool
}

variable "bastion_access" {
  default     = ["anywhere"]
  description = "A list of CIDR blocks to which ssh access to the bastion host must be restricted. *anywhere* is equivalent to 0.0.0.0/0 and allows ssh access from anywhere."
  type        = list(string)
}

variable "bastion_image_id" {
  default     = "Autonomous"
  description = "The image id to use for bastion."
  type        = string
}

variable "bastion_os_version" {
  description = "In case Autonomous Linux is used, allow specification of Autonomous version"
  default     = "7.9"
  type        = string
}

variable "bastion_shape" {
  default = {
    shape            = "VM.Standard.E4.Flex",
    ocpus            = 1,
    memory           = 4,
    boot_volume_size = 50
  }
  description = "The shape of bastion instance."
  type        = map(any)
}

variable "bastion_state" {
  description = "The target state for the bastion instance. Could be set to RUNNING or STOPPED. (Updatable)"
  default     = "RUNNING"
  type        = string
  validation {
    condition     = contains(["RUNNING", "STOPPED"], var.bastion_state)
    error_message = "Accepted values are RUNNING or STOPPED."
  }
}

variable "bastion_timezone" {
  default     = "Australia/Sydney"
  description = "The preferred timezone for the bastion host."
  type        = string
}

variable "bastion_type" {
  description = "Whether to make the bastion host public or private."
  default     = "public"
  type        = string

  validation {
    condition     = contains(["public", "private"], var.bastion_type)
    error_message = "Accepted values are public or private."
  }
}

variable "upgrade_bastion" {
  default     = true
  description = "Whether to upgrade the bastion host packages after provisioning. it’s useful to set this to false during development so the bastion is provisioned faster."
  type        = bool
}

## bastion notification parameters
variable "enable_bastion_notification" {
  default     = false
  description = "Whether to enable notification on the bastion host."
  type        = bool
}

variable "bastion_notification_endpoint" {
  default     = "none"
  description = "The subscription notification endpoint for the bastion. The email address to be notified."
  type        = string
}

variable "bastion_notification_protocol" {
  default     = "EMAIL"
  description = "The notification protocol used."
  type        = string
}

variable "bastion_notification_topic" {
  default     = "bastion"
  description = "The name of the notification topic."
  type        = string
}

# bastion service parameters
variable "create_bastion_service" {
  default     = false
  description = "Whether to create a bastion service that allows access to private hosts."
  type        = bool
}

variable "bastion_service_access" {
  default     = ["0.0.0.0/0"]
  description = "A list of CIDR blocks to which ssh access to the bastion service must be restricted. *anywhere* is equivalent to 0.0.0.0/0 and allows ssh access from anywhere."
  type        = list(string)
}

variable "bastion_service_target_subnet" {
  default     = "operator"
  description = "The name of the subnet that the bastion service can connect to."
  type        = string
}

# operator host parameters

variable "create_operator" {
  default     = true
  description = "Whether to create an operator server in a private subnet."
  type        = bool
}

variable "operator_image_id" {
  default     = "Oracle"
  description = "The image id to use for operator server. Set either an image id or to Oracle. If value is set to Oracle, the default Oracle Linux platform image will be used."
  type        = string
}

variable "enable_operator_instance_principal" {
  default     = true
  description = "Whether to enable the operator to call OCI API services without requiring api key."
  type        = bool
}

variable "operator_nsg_ids" {
  description = "An optional and updatable list of network security groups that the operator will be part of."
  type        = list(string)
  default     = []
}

variable "operator_os_version" {
  default     = "8"
  description = "The Oracle Linux version to use for the operator host"
  type        = string
}

variable "operator_shape" {
  default = {
    shape            = "VM.Standard.E4.Flex",
    ocpus            = 1,
    memory           = 4,
    boot_volume_size = 50
  }
  description = "The shape of operator instance."
  type        = map(any)
}

variable "operator_state" {
  description = "The target state for the operator instance. Could be set to RUNNING or STOPPED. (Updatable)"
  default     = "RUNNING"
  type        = string
  validation {
    condition     = contains(["RUNNING", "STOPPED"], var.operator_state)
    error_message = "Accepted values are RUNNING or STOPPED."
  }

}

variable "operator_timezone" {
  default     = "Australia/Sydney"
  description = "The preferred timezone for the operator host."
  type        = string
}

variable "upgrade_operator" {
  default     = true
  description = "Whether to upgrade the operator packages after provisioning. It’s useful to set this to false during development so the operator is provisioned faster."
  type        = bool
}

## operator notification parameters
variable "enable_operator_notification" {
  default     = false
  description = "Whether to enable notification on the operator host."
  type        = bool
}

variable "operator_notification_endpoint" {
  default     = "none"
  description = "The subscription notification endpoint for the operator. Email address to be notified."
  type        = string
}

variable "operator_notification_protocol" {
  default     = "EMAIL"
  description = "The notification protocol used."
  type        = string
}

variable "operator_notification_topic" {
  description = "The name of the notification topic."
  default     = "operator"
  type        = string
}

# availability domains
variable "availability_domains" {
  description = "Availability Domains where to provision non-OKE resources"
  default = {
    bastion  = 1
    operator = 1
  }
  type = map(any)
}

# oke cluster options
variable "admission_controller_options" {
  default = {
    PodSecurityPolicy = false
  }
  description = "various Admission Controller options"
  type        = map(bool)
}

variable "allow_node_port_access" {
  default     = false
  description = "Whether to allow access to NodePorts when worker nodes are deployed in public mode."
  type        = bool
}

variable "allow_worker_internet_access" {
  default     = true
  description = "Allow worker nodes to egress to internet. Required if container images are in a registry other than OCIR."
  type        = bool
}

variable "allow_worker_ssh_access" {
  default     = false
  description = "Whether to allow ssh access to worker nodes."
  type        = bool
}

variable "cluster_name" {
  default     = "oke"
  description = "The name of oke cluster."
  type        = string
}

variable "control_plane_type" {
  default     = "public"
  description = "Whether to allow public or private access to the control plane endpoint"
  type        = string

  validation {
    condition     = contains(["public", "private"], var.control_plane_type)
    error_message = "Accepted values are public, or private."
  }
}

variable "control_plane_allowed_cidrs" {
  default     = []
  description = "The list of CIDR blocks from which the control plane can be accessed."
  type        = list(string)
}

variable "control_plane_nsgs" {
  default     = []
  description = "An additional list of network security groups (NSG) ids for the cluster endpoint that can be created subsequently."
  type        = list(string)
}

variable "dashboard_enabled" {
  default     = false
  description = "Whether to enable kubernetes dashboard."
  type        = bool
}

variable "kubernetes_version" {
  default     = "v1.20.11"
  description = "The version of kubernetes to use when provisioning OKE or to upgrade an existing OKE cluster to."
  type        = string
}

variable "pods_cidr" {
  default     = "10.244.0.0/16"
  description = "The CIDR range used for IP addresses by the pods. A /16 CIDR is generally sufficient. This CIDR should not overlap with any subnet range in the VCN (it can also be outside the VCN CIDR range)."
  type        = string
}

variable "services_cidr" {
  default     = "10.96.0.0/16"
  description = "The CIDR range used by exposed Kubernetes services (ClusterIPs). This CIDR should not overlap with the VCN CIDR range."
  type        = string
}

## oke cluster kms integration

variable "use_encryption" {
  description = "Whether to use OCI KMS to encrypt Kubernetes secrets."
  default     = false
  type        = bool
}

variable "kms_key_id" {
  default     = ""
  description = "The id of the OCI KMS key to be used as the master encryption key for Kubernetes secrets encryption."
  type        = string
}

## oke cluster container image policy and keys
variable "use_signed_images" {
  description = "Whether to enforce the use of signed images. If set to true, at least 1 RSA key must be provided through image_signing_keys."
  default     = false
  type        = bool
}

variable "image_signing_keys" {
  description = "A list of KMS key ids used by the worker nodes to verify signed images. The keys must use RSA algorithm."
  type        = list(string)
  default     = []
}

# node pools
variable "check_node_active" {
  description = "check worker node is active"
  type        = string
  default     = "none"

  validation {
    condition     = contains(["none", "one", "all"], var.check_node_active)
    error_message = "Accepted values are none, one or all."
  }
}

variable "node_pools" {
  default = {
    np1 = { shape = "VM.Standard.E4.Flex", ocpus = 1, memory = 16, node_pool_size = 1, boot_volume_size = 150, label = { app = "frontend", pool = "np1" } }
    np2 = { shape = "VM.Standard.E2.2", node_pool_size = 2, boot_volume_size = 150 }
    np3 = { shape = "VM.Standard.E2.2", node_pool_size = 1 }
  }
  description = "Tuple of node pools. Each key maps to a node pool. Each value is a tuple of shape (string),ocpus(number) , node_pool_size(number) and boot_volume_size(number)"
  type        = any
}

variable "node_pool_image_id" {
  default     = "none"
  description = "The ocid of a custom image to use for worker node."
  type        = string
}

variable "node_pool_name_prefix" {
  default     = "np"
  description = "The prefix of the node pool name."
  type        = string
}

variable "node_pool_os" {
  default     = "Oracle Linux"
  description = "The name of image to use."
  type        = string
}

variable "node_pool_os_version" {
  default     = "7.9"
  description = "The version of operating system to use for the worker nodes."
  type        = string
}

variable "worker_nsgs" {
  default     = []
  description = "An additional list of network security groups (NSG) ids for the worker nodes that can be created subsequently."
  type        = list(any)
}

variable "worker_type" {
  default     = "private"
  description = "Whether to provision public or private workers."
  type        = string
  validation {
    condition     = contains(["public", "private"], var.worker_type)
    error_message = "Accepted values are public or private."
  }
}

# upgrade of existing node pools
variable "upgrade_nodepool" {
  default     = false
  description = "Whether to upgrade the Kubernetes version of the node pools."
  type        = bool
}

variable "node_pools_to_drain" {
  default     = ["none"]
  description = "List of node pool names to drain during an upgrade. This list is used to determine the worker nodes to drain."
  type        = list(string)
}

variable "nodepool_upgrade_method" {
  default     = "out_of_place"
  description = "The upgrade method to use when upgrading to a new version. Only out-of-place supported at the moment."
  type        = string
}

# oke load balancers

## waf
variable "enable_waf" {
  description = "Whether to enable WAF monitoring of load balancers"
  type        = bool
  default     = false
}

variable "load_balancers" {
  # values: both, internal, public
  default     = "public"
  description = "The type of subnets to create for load balancers."
  type        = string
  validation {
    condition     = contains(["public", "internal", "both"], var.load_balancers)
    error_message = "Accepted values are public, internal or both."
  }
}

variable "preferred_load_balancer" {
  # values: public, internal.
  # When creating an internal load balancer, the internal annotation must still be specified regardless 
  default     = "public"
  description = "The preferred load balancer subnets that OKE will automatically choose when creating a load balancer. valid values are public or internal. if 'public' is chosen, the value for load_balancers must be either 'public' or 'both'. If 'private' is chosen, the value for load_balancers must be either 'internal' or 'both'."
  type        = string
  validation {
    condition     = contains(["public", "internal"], var.preferred_load_balancer)
    error_message = "Accepted values are public or internal."
  }
}

## Allowed cidrs and ports for load balancers
variable "internal_lb_allowed_cidrs" {
  default     = ["0.0.0.0/0"]
  description = "The list of CIDR blocks from which the internal load balancer can be accessed."
  type        = list(string)

  validation {
    condition     = length(var.internal_lb_allowed_cidrs) > 0
    error_message = "At least 1 CIDR block is required."
  }
}

variable "internal_lb_allowed_ports" {
  default     = [80, 443]
  description = "List of allowed ports for internal load balancers."
  type        = list(any)

  validation {
    condition     = length(var.internal_lb_allowed_ports) > 0
    error_message = "At least 1 port is required."
  }
}

variable "public_lb_allowed_cidrs" {
  default     = ["0.0.0.0/0"]
  description = "The list of CIDR blocks from which the public load balancer can be accessed."
  type        = list(string)

  validation {
    condition     = length(var.public_lb_allowed_cidrs) > 0
    error_message = "At least 1 CIDR block is required."
  }
}

variable "public_lb_allowed_ports" {
  default     = [443]
  description = "List of allowed ports for public load balancers."
  type        = list(any)

  validation {
    condition     = length(var.public_lb_allowed_ports) > 0
    error_message = "At least 1 port is required."
  }
}

# ocir

variable "email_address" {
  default     = "none"
  description = "The email address used for OCIR."
  type        = string
}

variable "ocir_urls" {
  # Region and region codes: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/regions.htm#ServiceAvailabilityAcrossRegions
  description = "The urls of ocir in the respective regions."
  default = {
    ap-melbourne-1  = "mel.ocir.io"
    ap-hyderabad-1  = "hyd.ocir.io"
    ap-mumbai-1     = "bom.ocir.io"
    ap-osaka-1      = "kix.ocir.io"
    ap-singapore-1  = "sin.ocir.io"
    ap-seoul-1      = "icn.ocir.io"
    ap-chuncheon-1  = "yny.ocir.io"
    ap-sydney-1     = "syd.ocir.io"
    ap-tokyo-1      = "nrt.ocir.io"
    ca-montreal-1   = "yul.ocir.io"
    ca-toronto-1    = "yyz.ocir.io"
    eu-amsterdam-1  = "ams.ocir.io"
    eu-frankfurt-1  = "fra.ocir.io"
    eu-marseille-1  = "mrs.ocir.io"
    eu-milan-1      = "lin.ocir.io"
    eu-stockholm-1  = "arn.ocir.io"
    eu-zurich-1     = "zrh.ocir.io"
    il-jerusalem-1  = "mtz.ocir.io"
    me-abudhabi-1   = "auh.ocir.io"
    me-dubai-1      = "dxb.ocir.io"
    me-jeddah-1     = "jed.ocir.io"
    sa-santiago-1   = "scl.ocir.io"
    sa-saopaulo-1   = "gru.ocir.io"
    sa-vinhedo-1    = "vcp.ocir.io"
    uk-london-1     = "lhr.ocir.io"
    uk-cardiff-1    = "cwl.ocir.io"
    us-ashburn-1    = "iad.ocir.io"
    us-phoenix-1    = "phx.ocir.io"
    us-sanjose-1    = "sjc.ocir.io"
  }
  type = map(string)
}

variable "secret_id" {
  description = "The OCID of the Secret on OCI Vault which holds the authentication token."
  type        = string
  default     = "none"
}

variable "secret_name" {
  description = "The name of the Kubernetes secret that will hold the authentication token"
  type        = string
  default     = "ocirsecret"
}

variable "secret_namespace" {
  default     = "default"
  description = "The Kubernetes namespace for where the OCIR secret will be created."
  type        = string
}

variable "username" {
  default     = "none"
  description = "The username that can login to the selected tenancy. This is different from tenancy_id. *Required* if secret_id is set."
  type        = string
}

# calico
variable "enable_calico" {
  description = "Whether to install calico for network pod security policy"
  default     = false
  type        = bool
}

variable "calico_version" {
  description = "The version of calico to install"
  default     = "3.19"
  type        = string
}

# horizontal and vertical pod autoscaling
variable "enable_metric_server" {
  description = "Whether to install metricserver for collecting metrics and for HPA"
  default     = false
  type        = bool
}

variable "enable_vpa" {
  description = "Whether to install vertical pod autoscaler"
  default     = false
  type        = bool
}

variable "vpa_version" {
  description = "The version of vertical pod autoscaler to install"
  default     = "0.8"
}

#Gatekeeper
variable "enable_gatekeeper" {
  type        = bool
  default     = false
  description = "Whether to install Gatekeeper"
}

variable "gatekeeeper_version" {
  type        = string
  default     = "3.7"
  description = "The version of Gatekeeper to install"
}

# serviceaccount

variable "create_service_account" {
  description = "Whether to create a service account. A service account is required for CI/CD. see https://docs.cloud.oracle.com/iaas/Content/ContEng/Tasks/contengaddingserviceaccttoken.htm"
  default     = false
  type        = bool
}

variable "service_account_name" {
  description = "The name of service account to create"
  default     = "kubeconfigsa"
  type        = string
}

variable "service_account_namespace" {
  description = "The Kubernetes namespace where to create the service account"
  default     = "kube-system"
  type        = string
}

variable "service_account_cluster_role_binding" {
  description = "The cluster role binding name"
  default     = "cluster-admin"
  type        = string
}

# tagging
variable "freeform_tags" {
  default = {
    # vcn, bastion and operator tags are required
    # add more tags in each as desired
    vcn = {
      environment = "dev"
    }
    bastion = {
      environment = "dev"
      role        = "bastion"
    }
    operator = {
      environment = "dev"
      role        = "operator"
    }
  }
  description = "Tags to apply to different resources."
  type        = map(any)
}

# placeholder variable for debugging scripts. To be implemented in future
variable "debug_mode" {
  default     = false
  description = "Whether to turn on debug mode."
  type        = bool
}


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
