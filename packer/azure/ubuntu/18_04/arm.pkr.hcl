variable "use_azure_cli_auth" {
  type    = bool
  default = true
}

variable "resource_group" {
  type    = string
  default = "cloudmonk"
}

variable "image_name" {
  type    = string
  default = "K8sToolsetImage"
}

variable "image_name_prefix" {
  type    = string
  default = "SpringOne2021"
}

variable "init_script" {
  type    = string
  default = "init.sh"
}

variable "vm_size" {
  type    = string
  default = "Standard_D4d_v4"
}

variable "cloud_environment_name" {
  type    = string
  default = "Public"
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source

source "azure-arm" "k8s-toolset" {
  use_azure_cli_auth                   = var.use_azure_cli_auth
  cloud_environment_name               = var.cloud_environment_name                   # One of Public, China, Germany, or USGovernment. Defaults to Public. Long forms such as USGovernmentCloud and AzureUSGovernmentCloud are also supported.
  managed_image_storage_account_type   = "Standard_LRS"
  build_resource_group_name            = var.resource_group
  managed_image_resource_group_name    = var.resource_group
  managed_image_name                   = var.image_name
  os_type                              = "Linux"
  os_disk_size_gb                      = 50
  image_publisher                      = "Canonical"                                  # e.g., az vm image list-publishers --location westus2 -o table
  image_offer                          = "UbuntuServer"                               # e.g., az vm image list-offers --location westus2 --publisher Canonical -o table
  image_sku                            = "18.04-LTS"                                  # e.g., az vm image list-skus --location westus2 --publisher Canonical --offer 0001-com-ubuntu-minimal-focal-daily -o table
  image_version                        = "latest"
  vm_size                              = var.vm_size                                  # e.g., az vm list-sizes --location westus -o table
  ssh_username                         = "ubuntu"
}


# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build

build {
  sources = ["source.azure-arm.k8s-toolset"]

  provisioner "file" {
    source      = "dist/tanzu"
    destination = "/home/ubuntu/tanzu"
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
      "chmod +x /home/ubuntu/kind-load-cafile.sh"
    ]
  }

  provisioner "shell" {
    script = var.init_script
    # @see https://www.packer.io/docs/provisioners/shell#sudo-example
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
    ]
    inline_shebang = "/bin/sh -x"
  }

  post-processor "checksum" {
    checksum_types = ["md5", "sha512"]
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
