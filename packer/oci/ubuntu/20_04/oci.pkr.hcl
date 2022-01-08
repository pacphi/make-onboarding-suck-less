packer {
  required_plugins {
    oracle = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/oracle"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

variable "image_name" {
  type    = string
  default = "springone-2021-k8s-toolset-image"
}

variable "machine_type" {
  type    = string
  default = "VM.Standard2.2"
}

variable "init_script" {
  type    = string
  default = "init.sh"
}

variable "access_cfg_file" {
  type    = string
  default = "~/.oci/config"
}

variable "key_file" {
  type    = string
  default = "~/.oci/oci_api_key.pem"
}

variable "region" {
  type    = string
  default = "us-phoenix-1"
}

variable "availability_domain" {
  type    = string
  default = "imYr:PHX-AD-3"
}

variable "compartment_ocid" {
  type    = string
  default = ""
}

variable "subnet_ocid" {
  type    = string
  default = ""
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source

source "oracle-oci" "k8s-toolset" {
  access_cfg_file     = var.access_cfg_file
  key_file            = var.key_file
  compartment_ocid    = var.compartment_ocid
  region              = var.region
  availability_domain = var.availability_domain
  base_image_filter {
    operating_system         = "Canonical Ubuntu"
    operating_system_version = "20.04"
    display_name_search      = "^Canonical-Ubuntu-20\\.04-2021\\.\\d+"
  }
  image_name              = "${var.image_name}-${local.timestamp}"
  shape                   = var.machine_type
  ssh_username            = "ubuntu"
  subnet_ocid             = var.subnet_ocid
  tags = {
    CreationDate = "${local.timestamp}"
  }
  disk_size = 80
}


# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build

build {

  name = "with-tanzu"

  sources = [
    "source.oracle-oci.k8s-toolset"
  ]

  provisioner "file" {
    source      = "dist/"
    destination = "/home/ubuntu"
  }

  provisioner "file" {
    source      = "fetch-tanzu-cli.sh"
    destination = "/home/ubuntu/fetch-tanzu-cli.sh"
  }

  provisioner "file" {
    source      = "fetch-and-install-oci-cli.sh"
    destination = "/home/ubuntu/fetch-and-install-oci-cli.sh"
  }

  provisioner "file" {
    source      = "inventory.sh"
    destination = "/home/ubuntu/inventory.sh"
  }

  provisioner "file" {
    source      = "kind-load-cafile.sh"
    destination = "/home/ubuntu/kind-load-cafile.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /home/ubuntu/tanzu",
      "chmod +x /home/ubuntu/inventory.sh",
      "chmod +x /home/ubuntu/kind-load-cafile.sh",
      "chmod +x /home/ubuntu/fetch-tanzu-cli.sh",
      "chmod +x /home/ubuntu/fetch-and-install-oci-cli.sh"
    ]
  }

  provisioner "shell" {
    script = var.init_script
    # @see https://www.packer.io/docs/provisioners/shell#sudo-example
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  post-processor "checksum" {
    checksum_types = ["md5", "sha512"]
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}

build {

  name = "standard"

  sources = [
    "source.oracle-oci.k8s-toolset"
  ]

  provisioner "file" {
    source      = "fetch-tanzu-cli.sh"
    destination = "/home/ubuntu/fetch-tanzu-cli.sh"
  }

  provisioner "file" {
    source      = "fetch-and-install-oci-cli.sh"
    destination = "/home/ubuntu/fetch-and-install-oci-cli.sh"
  }

  provisioner "file" {
    source      = "inventory.sh"
    destination = "/home/ubuntu/inventory.sh"
  }

  provisioner "file" {
    source      = "kind-load-cafile.sh"
    destination = "/home/ubuntu/kind-load-cafile.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /home/ubuntu/inventory.sh",
      "chmod +x /home/ubuntu/kind-load-cafile.sh",
      "chmod +x /home/ubuntu/fetch-tanzu-cli.sh",
      "chmod +x /home/ubuntu/fetch-and-install-oci-cli.sh"
    ]
  }

  provisioner "shell" {
    script = var.init_script
    # @see https://www.packer.io/docs/provisioners/shell#sudo-example
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  post-processor "checksum" {
    checksum_types = ["md5", "sha512"]
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
