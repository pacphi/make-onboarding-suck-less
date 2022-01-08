packer {
  required_plugins {
    googlecompute = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/googlecompute"
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

variable "project_id" {
  type = string
  default = "fe-cphillipson"
}

variable "machine_type" {
  type    = string
  default = "e2-standard-4"
}

variable "init_script" {
  type    = string
  default = "init.sh"
}

variable "zone" {
  type    = string
  default = "us-west2-c"
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source

source "googlecompute" "k8s-toolset" {
  project_id          = var.project_id
  image_name          = "${var.image_name}-${local.timestamp}"
  enable_secure_boot  = true
  machine_type        = var.machine_type
  source_image_family = "ubuntu-minimal-2004-lts"
  ssh_username        = "ubuntu"
  zone                = var.zone
  disk_size           = 50
  disk_type           = "pd-ssd"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build

build {

  name = "with-tanzu"

  sources = [
    "source.googlecompute.k8s-toolset"
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
    "source.googlecompute.k8s-toolset"
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
