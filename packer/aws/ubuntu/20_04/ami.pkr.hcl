packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

variable "ami_name" {
  type    = string
  default = "springone-2021-k8s-toolset-image"
}

variable "init_script" {
  type    = string
  default = "init.sh"
}

variable "instance_type" {
  type    = string
  default = "m5a.xlarge"
}

variable "vpc_region" {
  type    = string
  default = "us-west-2"
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source

source "amazon-ebs" "k8s-toolset" {
  associate_public_ip_address = true
  ami_groups                  = ["all"]
  ami_name                    = "${var.ami_name}-${local.timestamp}"
  instance_type               = var.instance_type
  region                      = var.vpc_region
  ssh_pty                     = "true"
  ssh_timeout                 = "120m"
  ssh_username                = "ubuntu"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 30
    volume_type           = "gp2"
    delete_on_termination = true
  }
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build

build {

  name = "with-tanzu"

  sources = [
    "source.amazon-ebs.k8s-toolset"
  ]

  provisioner "file" {
    source      = "dist/tanzu"
    destination = "/home/ubuntu/tanzu"
  }

  provisioner "file" {
    source      = "fetch-tanzu-cli.sh"
    destination = "/home/ubuntu/fetch-tanzu-cli.sh"
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
      "chmod +x /home/ubuntu/fetch-tanzu-cli.sh"
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
    "source.amazon-ebs.k8s-toolset"
  ]

  provisioner "file" {
    source      = "fetch-tanzu-cli.sh"
    destination = "/home/ubuntu/fetch-tanzu-cli.sh"
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
      "chmod +x /home/ubuntu/fetch-tanzu-cli.sh"
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