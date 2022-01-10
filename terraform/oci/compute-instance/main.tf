data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "i" {
  compartment_id           = var.compute_instance_compartment_ocid
  operating_system         = local.instance_os
  operating_system_version = local.os_version
  shape                    = var.compute_instance_shape

  filter {
    name   = "display_name"
    values = ["^.*Ubuntu[^G]*$"]
    regex  = true
  }
}

data "template_file" "init_script" {
  template = file("./templates/init.tpl")
  vars = {
    ssh_public_key = "${file(var.ssh_public_key_path)}"
    region = var.region
    fingerprint = var.fingerprint
    tenancy_ocid = var.tenancy_ocid
    user_ocid = var.user_ocid
    oci_pk_file_contents = "${file(var.oci_private_key_path)}"
  }
}

data "template_cloudinit_config" "cloud_init" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "ainit.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.init_script.rendered
  }
}

resource "oci_core_instance" "compute_instance" {

  display_name = var.compute_instance_name
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id = var.compute_instance_compartment_ocid
  shape = var.compute_instance_shape

  source_details {
    source_id = var.source_image_ocid != "" ? var.source_image_ocid : data.oci_core_images.i.images[0].id
    source_type = "image"
  }

  create_vnic_details {
    subnet_id = var.compute_instance_subnet_ocid
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = "${file(var.ssh_public_key_path)}"
    user_data = data.template_cloudinit_config.cloud_init.rendered
  }

  dynamic "shape_config" {
    for_each = local.is_flexible_compute_instance_shape ? [1] : []
    content {
      memory_in_gbs = var.compute_instance_memory
      ocpus         = var.compute_instance_ocpus
    }
  }

  preserve_boot_volume = false
}