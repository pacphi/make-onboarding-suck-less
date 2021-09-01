# Make Onboarding Suck Less

> A Spring One 2021 [session](https://springone.io/2021/sessions/making-onboarding-suck-less).

Experiments with Docker, Packer and Vagrant. Striving to make it easy for varying persona to get started with a curated collection of tooling packaged and available on popular OSes.  All while standing on the shoulders of giants.

## Prerequisites

* [VirtualBox](https://www.virtualbox.org/wiki/Download_Old_Builds_6_1)
  * VirtualBox Extension Pack
    > Make sure the version the extension pack you install matches the version of VirtualBox installed on the host machine.
* [Vagrant](https://www.vagrantup.com/downloads)
* [Packer](https://www.packer.io/downloads)
* [Docker](https://docs.docker.com/get-docker/)
* [vmw-cli](https://github.com/apnex/vmw-cli)

For your convenience a set of scripts exist to install the complement of prerequisites listed above on (any of the following host OSes):

* [MacOS](scripts/install-prereqs-macos.sh) >= 10.15
* [Ubuntu](scripts/install-prereqs-linux.sh) >= 20.04
* [Windows](scripts/install-prereqs-windows.ps1) >= 10

## Tools used to curate toolsets

_Vagrant_ is used to create and start a VM on a host OS. That VM, your choice of _MacOS_, _Ubuntu_, or _Windows_ has tools curated for a Kubernetes operator or developer.  You could certainly craft other variants.  (Use case: get toolset ready for consumption on a laptop or workstation).

_Docker_ is employed along with a Dockerfile to curate the same.

_Packer_ is used to create a VM image that can then be instantiated as a VM in a target public cloud. Examples focus on standing up Ubuntu, but you could very well stand up a Windows VM. (Use case: launch a jumpbox in a Virtual Private Network).

The choice of tools used to package is not the focus rather the above are introduced as a means to curate and automate packaging of toolsets for a typical enterprise persona.  Adopting and maintaining automation around curation of toolsets should help make onboarding less of a chore.


## Examples

### Found here

* Vagrant
  * [MacOS 10.15](vagrant/macos/10_15)
  * [Ubuntu 20.04](vagrant/ubuntu/20_04)
  * [Windows 10](vagrant/windows/10)
* Docker
  * [Ubuntu 20.04](docker/README.md)
* Packer
  * [Ubuntu 20.04 on Google Compute VM](packer/google/ubuntu/20_04)
  * [Ubuntu 20.04 on Amazon EC2](packer/aws/ubuntu/20_04)
  * [Ubuntu 20.04 on Azure VM](packer/azure/ubuntu/18_04)

### Elsewhere

* [alicloud-image-builder](https://alibabacloud-howto.github.io/devops/tutorials/devops_for_small_to_medium_web_applications/part_04_continuous_delivery.html)
* [ibm-cloud-image-builder](https://github.com/IBM-Cloud/ibmcloud-image-builder)
* [oci-image-builder](https://github.com/oracle-quickstart/oci-byo-image)
* [vmware-vsphere-image-builder](https://github.com/allthingsclowd/packer-vsphere-iso-example)


## What if I'm air-gapped?

Host your own artifact repository within your own network. Mirror or package and maintain artifacts.

A solid choice:

* Artifactory
  * [Docker](https://www.jfrog.com/confluence/display/JFROG/Docker+Registry)
  * [Vagrant](https://www.jfrog.com/confluence/display/JFROG/Vagrant+Repositories)

Incorporate scanning to watch for critical security vulnerabilities (and gate consumption of the same).

Consider:

* [Snyk](https://snyk.io/product/container-vulnerability-management/)
* [Tenable](https://www.tenable.com/)


## CI/CD Ideas

* GitHub Actions
  * [setup-packer](https://github.com/marketplace/actions/setup-packer)
  * [vagrant-github-actions](https://github.com/jonashackt/vagrant-github-actions)
* [Start GitHub Actions self-hosted runner with VirtualBox and Vagrant ](https://dev.to/peaceiris/start-github-actions-self-hosted-runner-with-virtualbox-and-vagrant-49ei)
* [Using GitLab CI/CD Pipelines to Automate your HashiCorp Packer Builds](https://virtualhobbit.com/2020/05/05/using-gitlab-ci-cd-pipelines-to-automate-your-hashicorp-packer-builds/)


## Cloud IDEs

* [AWS Cloud9](https://aws.amazon.com/cloud9/)
* [GitHub Codespaces](https://github.com/features/codespaces)
* [Google Cloud Shell](https://cloud.google.com/shell)
* [Red Hat CodeReady Workspaces](https://developers.redhat.com/products/codeready-workspaces/overview)
