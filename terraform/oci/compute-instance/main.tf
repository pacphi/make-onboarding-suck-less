data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "template_file" "cloud-config" {
  template = <<YAML
#cloud-config
runcmd:
 - echo 'This instance was provisioned by Terraform.' >> /etc/motd
YAML
}

resource "oci_core_instance" "compute_instance" {
  # Required
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id = var.compute_instance_compartment_ocid
  shape = var.compute_instance_shape
  source_details {
    source_id = var.compute_instance_source_image_ocid
    source_type = "image"
  }

  # Optional
  display_name = var.compute_instance_name
  create_vnic_details {
    assign_public_ip = true
    subnet_id = var.compute_instance_subnet_ocid
  }

  metadata = {
    ssh_authorized_keys = "${file(var.ssh_public_key_path)}"
    user_data = "${base64encode(data.template_file.cloud-config.rendered)}"
  }

  preserve_boot_volume = false
}