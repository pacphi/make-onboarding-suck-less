# Make Onboarding Suck Less

Experiments with Docker, Packer and Vagrant. Striving to make it easy for varying persona to get started with a curated collection of tooling packaged and available on popular OSes.  All while standing on the shoulders of giants.

## Prerequisites

* [VirtualBox](https://www.virtualbox.org/wiki/Download_Old_Builds_6_1)
  * VirtualBox Extension Pack
    > Make sure the version the extension pack you install matches the version of VirtualBox installed on the host machine.
* [Vagrant](https://www.vagrantup.com/downloads)
* [Packer](https://www.packer.io/downloads)
* [Docker](https://docs.docker.com/get-docker/)


## Tools used to curate toolsets

_Vagrant_ is used to create and start a VM on a host OS. That VM, your choice of _MacOS_, _Ubuntu_, or _Windows_ has tools curated for a Kubernetes operator or developer. (You could certainly craft other variants).

_Docker_ is employed along with a Dockerfile to curate the same.

_Packer_ is used to create a VM image that can then be instantiated as a VM in a target public cloud. Examples focus on standing up Ubuntu, but you could very well stand up a Windows VM. (Use case: launch a jumpbox in a Virtual Private Network).

The choice of tools used to package is not the focus rather the above are introduced as a means to curate and automate packaging of toolsets for a typical enterprise persona.  Adopting and maintaining automation around curation of toolsets should help make onboarding less of a chore.


## Examples

* Vagrant
  * [MacOs 10.15](vagrant/mac0s/10_15)
  * [Ubuntu 20.04](vagrant/ubuntu/20_04)
  * [Windows 10](vagrant/windows/10)
* Docker
  * [Ubuntu 20.04](docker/README.md)
* Packer
  * [Ubuntu 20.04 on Google Compute VM](packer/google/ubuntu/20_04)
  * [Ubuntu 20.04 on Amazon EC2](packer/aws/ubuntu/20_04)
  * [Ubuntu 18.04 on Azure VM](packer/azure/ubuntu/18_04)

## Cloud IDEs

* [AWS Cloud9](https://aws.amazon.com/cloud9/)
* [GitHub Codespaces](https://github.com/features/codespaces)
* [Google Cloud Shell](https://cloud.google.com/shell)
* [Red Hat CodeReady Workspaces](https://developers.redhat.com/products/codeready-workspaces/overview)