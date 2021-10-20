#!/bin/bash -e

main() {
  # @see https://github.com/hashicorp/packer/issues/2639
  /usr/bin/cloud-init status --wait

  # Manage software versions installed here
  TZ=America/Los_Angeles
  ARGO_VERSION=3.1.14
  ARGOCD_VERSION=2.1.4
  BOSH_VERSION=6.4.7
  CF_VERSION=7.3.0
  CREDHUB_VERSION=2.9.0
  GH_VERSION=2.1.0
  GO_VERSION=1.17
  HELM_VERSION=3.7.0
  HELMFILE_VERSION=0.141.0
  AWS_IAM_AUTHENTICATOR_VERSION="1.21.2/2021-07-05"
  IMGPKG_VERSION=0.20.0
  KAPP_VERSION=0.42.0
  KBLD_VERSION=0.31.0
  KIND_VERSION=0.11.1
  KWT_VERSION=0.0.6
  KUBECTL_VERSION=1.22.1
  LEFTOVERS_VERSION=0.62.0
  OM_VERSION=7.3.2
  PIVNET_VERSION=3.0.1
  TEKTONCD_VERSION=0.21.0
  TERRAFORM_VERSION=1.0.9
  TERRAFORM_DOCS_VERSION=0.16.0
  TMC_VERSION=0.4.0-21354296
  VELERO_VERSION=1.7.0
  VENDIR_VERSION=0.23.0
  YTT_VERSION=0.37.0

  # Place ourselves in a temporary directory; don't clutter user.home directory w/ downloaded artifacts
  cd /tmp

  # Set timezone
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

  # Bring OS package management up-to-date
  apt update -y

  # Install packages from APT
  apt install build-essential curl default-jre git gpg graphviz gzip httpie libnss3-tools jq openssl pv python3-pip python3-dev ruby-dev snapd sudo tmux tree tzdata unzip wget -y
  apt install apt-transport-https ca-certificates gnupg lsb-release nano software-properties-common dirmngr -y
  add-apt-repository ppa:cncf-buildpacks/pack-cli
  apt install pack-cli -y

  # Install packages from Snap
  sudo snap install snap-store
  sudo snap install k9s
  sudo snap install yq

  # Install Python 3
  python3 -m pip install --user --upgrade pip
  python3 -m pip install --user virtualenv

  # Install Docker-CE
  useradd -m docker && echo "docker:docker" | chpasswd
  adduser docker sudo
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  sudo usermod -aG docker ubuntu
  sudo systemctl enable docker.service
  sudo systemctl enable containerd.service
  docker run --rm hello-world

  # Install AWS CLI
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install

  # Install AWS IAM Authenticator
  curl -o aws-iam-authenticator curl -o aws-iam-authenticator "https://amazon-eks.s3.us-west-2.amazonaws.com/${AWS_IAM_AUTHENTICATOR_VERSION}/bin/linux/amd64/aws-iam-authenticator"
  chmod +x aws-iam-authenticator
  sudo mv aws-iam-authenticator /usr/local/bin

  # Install Azure CLI
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

  # Install Google Cloud SDK
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
  apt update -y && apt install google-cloud-sdk -y

  # Install Cloud Foundry UAA CLI
  gem install cf-uaac

  # Install BOSH CLI
  wget https://github.com/cloudfoundry/bosh-cli/releases/download/v${BOSH_VERSION}/bosh-cli-${BOSH_VERSION}-linux-amd64
  mv bosh-cli-${BOSH_VERSION}-linux-amd64 bosh
  chmod +x bosh
  sudo mv bosh /usr/local/bin

  # Install Cloud Foundry CLI
  wget -O cf.tgz "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=${CF_VERSION}&source=github-rel"
  tar -xvf cf.tgz
  rm -Rf cf.tgz
  sudo mv cf7 cf
  sudo mv cf /usr/local/bin

  # Install Credhub CLI
  wget https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${CREDHUB_VERSION}/credhub-linux-${CREDHUB_VERSION}.tgz
  tar -xvzf credhub-linux-${CREDHUB_VERSION}.tgz
  rm -Rf credhub-linux-${CREDHUB_VERSION}.tgz
  sudo mv credhub /usr/local/bin

  # Install kubectl
  curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin

  # Install krew
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz"
  tar zxvf krew-linux_amd64.tar.gz
  KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/')"
  "$KREW" install krew
  echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> $HOME/.bashrc

  # Install Operations Manager CLI (for Cloud Foundry)
  wget https://github.com/pivotal-cf/om/releases/download/${OM_VERSION}/om-linux-${OM_VERSION}
  mv om-linux-${OM_VERSION} om
  chmod +x om
  sudo mv om /usr/local/bin

  # Install Tanzu Network CLI (formerly Pivotal Network CLI)
  wget https://github.com/pivotal-cf/pivnet-cli/releases/download/v${PIVNET_VERSION}/pivnet-linux-amd64-${PIVNET_VERSION}
  mv pivnet-linux-amd64-${PIVNET_VERSION} pivnet
  chmod +x pivnet
  sudo mv pivnet /usr/local/bin

  # Install Terraform
  wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  sudo mv terraform /usr/local/bin

  # Install Terraform-Docs
  curl -Lo ./terraform-docs https://github.com/segmentio/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-$(uname | tr '[:upper:]' '[:lower:]')-amd64
  chmod +x ./terraform-docs
  sudo mv terraform-docs /usr/local/bin

  # Install leftovers - helps to clean up orphaned resources created in a public cloud
  wget https://github.com/genevieve/leftovers/releases/download/v${LEFTOVERS_VERSION}/leftovers-v${LEFTOVERS_VERSION}-linux-amd64
  mv leftovers-v${LEFTOVERS_VERSION}-linux-amd64 leftovers
  chmod +x leftovers
  sudo mv leftovers /usr/local/bin

  # Install Tanzu Mission Control CLI
  curl -LO https://tmc-cli.s3-us-west-2.amazonaws.com/tmc/${TMC_VERSION}/linux/x64/tmc
  chmod +x tmc
  sudo mv tmc /usr/local/bin

  # Install Helm
  curl -LO "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz"
  tar -xvf helm-v${HELM_VERSION}-linux-amd64.tar.gz
  sudo mv linux-amd64/helm /usr/local/bin

  # Install Helmfile
  curl -Lo ./helmfile https://github.com/roboll/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_linux_amd64
  chmod +x helmfile
  sudo mv helmfile /usr/local/bin

  # Install full complement of Carvel toolset
  wget -O imgpkg https://github.com/vmware-tanzu/carvel-imgpkg/releases/download/v${IMGPKG_VERSION}/imgpkg-linux-amd64
  chmod +x imgpkg
  sudo mv imgpkg /usr/local/bin
  wget -O ytt https://github.com/vmware-tanzu/carvel-ytt/releases/download/v${YTT_VERSION}/ytt-linux-amd64
  chmod +x ytt
  sudo mv ytt /usr/local/bin
  wget -O vendir https://github.com/vmware-tanzu/carvel-vendir/releases/download/v${VENDIR_VERSION}/vendir-linux-amd64
  chmod +x vendir
  sudo mv vendir /usr/local/bin
  wget -O kapp https://github.com/vmware-tanzu/carvel-kapp/releases/download/v${KAPP_VERSION}/kapp-linux-amd64
  chmod +x kapp
  sudo mv kapp /usr/local/bin
  wget -O kbld https://github.com/vmware-tanzu/carvel-kbld/releases/download/v${KBLD_VERSION}/kbld-linux-amd64
  chmod +x kbld
  sudo mv kbld /usr/local/bin
  wget -O kwt https://github.com/vmware-tanzu/carvel-kwt/releases/download/v${KWT_VERSION}/kwt-linux-amd64
  chmod +x kwt
  sudo mv kwt /usr/local/bin

  # Install Minio CLI
  curl -LO https://dl.min.io/client/mc/release/linux-amd64/mc
  chmod +x mc
  sudo mv mc /usr/local/bin

  # Install Argo CD and Argo Workflows CLIs
  wget -O argocd https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-amd64
  chmod +x argocd
  sudo mv argocd /usr/local/bin
  curl -LO https://github.com/argoproj/argo-workflows/releases/download/v${ARGO_VERSION}/argo-linux-amd64.gz
  gunzip argo-linux-amd64.gz
  chmod +x argo-linux-amd64
  sudo mv argo-linux-amd64 /usr/local/bin/argo

  # Install Tekton CD CLI
  curl -LO https://github.com/tektoncd/cli/releases/download/v${TEKTONCD_VERSION}/tkn_${TEKTONCD_VERSION}_Linux_x86_64.tar.gz
  tar -xvf tkn_${TEKTONCD_VERSION}_Linux_x86_64.tar.gz
  chmod +x tkn
  sudo mv tkn /usr/local/bin

  # Install Github CLI
  curl -LO https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz
  tar -xvf gh_${GH_VERSION}_linux_amd64.tar.gz
  chmod +x gh_${GH_VERSION}_linux_amd64/bin/gh
  sudo mv gh_${GH_VERSION}_linux_amd64/bin/gh /usr/local/bin

  # Install Golang
  wget -c https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local
  sudo ln -s /usr/local/go/bin/go /usr/local/bin/go
  sudo ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

  # Install mkcert
  git clone https://github.com/FiloSottile/mkcert && cd mkcert
  go build -ldflags "-X main.Version=$(git describe --tags)"
  sudo mv mkcert /usr/local/bin
  cd ..
  rm -Rf mkcert

  # Install kind
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin

  # Install Velero
  curl -LO https://github.com/vmware-tanzu/velero/releases/download/v${VELERO_VERSION}/velero-v${VELERO_VERSION}-linux-amd64.tar.gz
  tar -xvf velero-v${VELERO_VERSION}-linux-amd64.tar.gz
  chmod +x velero-v${VELERO_VERSION}-linux-amd64/velero
  sudo mv velero-v${VELERO_VERSION}-linux-amd64/velero /usr/local/bin

  # Clean-up APT cache
  rm -Rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
  apt clean

  cd /home/ubuntu

  # Move Tanzu CLI into place (if it had been file provisioned)
  if [ -e "/home/ubuntu/tanzu" ]; then
    sudo mv /home/ubuntu/tanzu /usr/local/bin
  fi

  if [ -e "/home/ubuntu/tanzu-cli-bundle-linux-amd64.tar" ]; then
    tar xvf tanzu-cli-bundle-linux-amd64.tar -C .
  fi

}

main
