FROM ubuntu:20.10
LABEL author=cphillipson@vmware.com

ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=America/Los_Angeles \
    ARGO_VERSION=3.2.0 \
    ARGOCD_VERSION=2.1.4 \
    BOSH_VERSION=6.4.7 \
    CF_VERSION=7.3.0 \
    CREDHUB_VERSION=2.9.0 \
    GH_VERSION=2.1.0 \
    GO_VERSION=1.17 \
    HELM_VERSION=3.7.0 \
    HELMFILE_VERSION=0.141.0 \
    AWS_IAM_AUTHENTICATOR_VERSION="1.21.2/2021-07-05" \
    IMGPKG_VERSION=0.20.0 \
    KAPP_VERSION=0.42.0 \
    KBLD_VERSION=0.31.0 \
    KWT_VERSION=0.0.6 \
    KREW_VERSION=0.4.2 \
    KUBECTL_VERSION=1.22.1 \
    OM_VERSION=7.3.2 \
    PACK_VERSION=0.21.1 \
    PIVNET_VERSION=3.0.1 \
    TEKTONCD_VERSION=0.29.0 \
    TERRAFORM_VERSION=1.0.9 \
    TERRAFORM_DOCS_VERSION=0.16.0 \
    LEFTOVERS_VERSION=0.62.0 \
    TF_CARVEL_PLUGIN_VERSION=0.10.0 \
    TMC_VERSION=0.4.0-21354296 \
    VELERO_VERSION=1.7.0 \
    VENDIR_VERSION=0.23.0 \
    YTT_VERSION=0.37.0

RUN mkdir downloads && cd downloads && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt update -y && \
    apt install buildah build-essential curl default-jre git gpg graphviz gzip httpie libnss3-tools jq nodejs npm openssl podman pv python3-pip python3-dev ruby-dev sudo tmux tzdata unzip wget -y && \
    apt install apt-transport-https ca-certificates gnupg lsb-release software-properties-common dirmngr -y && \
    (curl -sSL "https://github.com/buildpacks/pack/releases/download/v${PACK_VERSION}/pack-v${PACK_VERSION}-linux.tgz" | sudo tar -C /usr/local/bin/ --no-same-owner -xzv pack) && \
    python3 -m pip install --user --upgrade pip && \
    python3 -m pip install --user virtualenv && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    sudo ./aws/install && \
    curl -o aws-iam-authenticator curl -o aws-iam-authenticator "https://amazon-eks.s3.us-west-2.amazonaws.com/${AWS_IAM_AUTHENTICATOR_VERSION}/bin/linux/amd64/aws-iam-authenticator" && \
    chmod +x aws-iam-authenticator && \
    sudo mv aws-iam-authenticator /usr/local/bin && \
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt update -y && apt install google-cloud-sdk -y && \
    gem install cf-uaac && \
    wget https://github.com/cloudfoundry/bosh-cli/releases/download/v${BOSH_VERSION}/bosh-cli-${BOSH_VERSION}-linux-amd64 && \
    mv bosh-cli-${BOSH_VERSION}-linux-amd64 bosh && \
    chmod +x bosh && \
    sudo mv bosh /usr/local/bin && \
    wget -O cf.tgz "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=${CF_VERSION}&source=github-rel" && \
    tar -xvf cf.tgz && \
    sudo mv cf7 cf && \
    sudo mv cf /usr/local/bin && \
    wget https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${CREDHUB_VERSION}/credhub-linux-${CREDHUB_VERSION}.tgz && \
    tar -xvzf credhub-linux-${CREDHUB_VERSION}.tgz && \
    sudo mv credhub /usr/local/bin && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && \
    sudo mv kubectl /usr/local/bin && \
    curl -LO "https://github.com/kubernetes-sigs/krew/releases/download/v$KREW_VERSION/krew.tar.gz" && \
    curl -LO "https://github.com/kubernetes-sigs/krew/releases/download/v$KREW_VERSION/krew.yaml" && \
    tar -xvzf krew.tar.gz && \
    sudo mv krew-linux_amd64 /usr/local/bin/krew && \
    krew install --manifest=krew.yaml && \
    wget https://github.com/pivotal-cf/om/releases/download/${OM_VERSION}/om-linux-${OM_VERSION} && \
    mv om-linux-${OM_VERSION} om && \
    chmod +x om && \
    sudo mv om /usr/local/bin && \
    wget https://github.com/pivotal-cf/pivnet-cli/releases/download/v${PIVNET_VERSION}/pivnet-linux-amd64-${PIVNET_VERSION} && \
    mv pivnet-linux-amd64-${PIVNET_VERSION} pivnet && \
    chmod +x pivnet && \
    sudo mv pivnet /usr/local/bin && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    sudo mv terraform /usr/local/bin && \
    curl -Lo ./terraform-docs https://github.com/segmentio/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-$(uname | tr '[:upper:]' '[:lower:]')-amd64 && \
    chmod +x ./terraform-docs && \
    sudo mv terraform-docs /usr/local/bin && \
    wget https://github.com/genevieve/leftovers/releases/download/v${LEFTOVERS_VERSION}/leftovers-v${LEFTOVERS_VERSION}-linux-amd64 && \
    mv leftovers-v${LEFTOVERS_VERSION}-linux-amd64 leftovers && \
    chmod +x leftovers && \
    sudo mv leftovers /usr/local/bin && \
    mkdir -p ~/.terraform.d/plugins && \
    curl -LO "https://github.com/vmware-tanzu/terraform-provider-carvel/releases/download/v${TF_CARVEL_PLUGIN_VERSION}/terraform-provider-carvel-binaries.tgz" && \
    tar xzvf terraform-provider-carvel-binaries.tgz -C ~/.terraform.d/plugins/ && \
    curl -LO https://tmc-cli.s3-us-west-2.amazonaws.com/tmc/${TMC_VERSION}/linux/x64/tmc && \
    chmod +x tmc && \
    mv tmc /usr/local/bin && \
    curl -LO "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" && \
    tar -xvf helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    sudo mv linux-amd64/helm /usr/local/bin && \
    curl -Lo ./helmfile https://github.com/roboll/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_linux_amd64 && \
    chmod +x helmfile && \
    sudo mv helmfile /usr/local/bin && \
    wget -O imgpkg https://github.com/vmware-tanzu/carvel-imgpkg/releases/download/v${IMGPKG_VERSION}/imgpkg-linux-amd64 && \
    chmod +x imgpkg && \
    sudo mv imgpkg /usr/local/bin && \
    wget -O ytt https://github.com/vmware-tanzu/carvel-ytt/releases/download/v${YTT_VERSION}/ytt-linux-amd64 && \
    chmod +x ytt && \
    sudo mv ytt /usr/local/bin && \
    wget -O vendir https://github.com/vmware-tanzu/carvel-vendir/releases/download/v${VENDIR_VERSION}/vendir-linux-amd64 && \
    chmod +x vendir && \
    sudo mv vendir /usr/local/bin && \
    wget -O kapp https://github.com/vmware-tanzu/carvel-kapp/releases/download/v${KAPP_VERSION}/kapp-linux-amd64 && \
    chmod +x kapp && \
    sudo mv kapp /usr/local/bin && \
    wget -O kbld https://github.com/vmware-tanzu/carvel-kbld/releases/download/v${KBLD_VERSION}/kbld-linux-amd64 && \
    chmod +x kbld && \
    sudo mv kbld /usr/local/bin && \
    wget -O kwt https://github.com/vmware-tanzu/carvel-kwt/releases/download/v${KWT_VERSION}/kwt-linux-amd64 && \
    chmod +x kwt && \
    sudo mv kwt /usr/local/bin && \
    curl -LO https://dl.min.io/client/mc/release/linux-amd64/mc && \
    chmod +x mc && \
    sudo mv mc /usr/local/bin && \
    wget -O argocd https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-amd64 && \
    chmod +x argocd && \
    sudo mv argocd /usr/local/bin && \
    curl -LO https://github.com/argoproj/argo-workflows/releases/download/v${ARGO_VERSION}/argo-linux-amd64.gz && \
    gunzip argo-linux-amd64.gz && \
    chmod +x argo-linux-amd64 && \
    sudo mv argo-linux-amd64 /usr/local/bin/argo && \
    curl -LO https://github.com/tektoncd/cli/releases/download/v${TEKTONCD_VERSION}/tkn_${TEKTONCD_VERSION}_Linux_x86_64.tar.gz && \
    tar -xvf tkn_${TEKTONCD_VERSION}_Linux_x86_64.tar.gz && \
    chmod +x tkn && \
    sudo mv tkn /usr/local/bin && \
    curl -LO https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz && \
    tar -xvf gh_${GH_VERSION}_linux_amd64.tar.gz && \
    chmod +x gh_${GH_VERSION}_linux_amd64/bin/gh && \
    sudo mv gh_${GH_VERSION}_linux_amd64/bin/gh /usr/local/bin && \
    wget -c https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local && \
    sudo ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    sudo ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt && \
    git clone https://github.com/FiloSottile/mkcert && cd mkcert && \
    go build -ldflags "-X main.Version=$(git describe --tags)" && \
    sudo mv mkcert /usr/local/bin && \
    curl -LO https://github.com/vmware-tanzu/velero/releases/download/v${VELERO_VERSION}/velero-v${VELERO_VERSION}-linux-amd64.tar.gz && \
    tar -xvf velero-v${VELERO_VERSION}-linux-amd64.tar.gz && \
    chmod +x velero-v${VELERO_VERSION}-linux-amd64/velero && \
    sudo mv velero-v${VELERO_VERSION}-linux-amd64/velero /usr/local/bin && \
    cd ../.. && \
    rm -Rf downloads /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt clean && \
    useradd -m docker && echo "docker:docker" | chpasswd && \
    adduser docker sudo && \
    npm install vmw-cli --global && \
    sudo chown -R docker /usr/local/lib/node_modules && \
    sudo chgrp -R docker /usr/local/lib/node_modules

USER docker

WORKDIR /home/docker

COPY dist/ /home/docker/

RUN if [ -e "/home/docker/tanzu-cli-bundle-linux-amd64.tar" ]; then echo "docker" | sudo -S mv /home/docker/tanzu /usr/local/bin && tar xvf tanzu-cli-bundle-linux-amd64.tar -C . && tanzu plugin clean && tanzu plugin install --local cli all && rm -Rf cli tanzu-cli-bundle-linux-amd64.tar; fi

CMD [ "/bin/bash" ]
