
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
  vcn_dns_label = "okevcn${random_string.suffix.result}"
  create_drg = var.create_drg
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
  enable_vpa = var.enable_vpa
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
