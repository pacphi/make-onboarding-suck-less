#!/usr/bin/env bash

echo "Argo CD CLI" && argocd version && echo
echo "Argo Workflows CLI" && argo version && echo
echo "Azure CLI" && az version && echo
echo "AWS CLI" && aws --version && echo
echo "AWS IAM Authenticator" && aws-iam-authenticator version && echo
echo "BOSH CLI" && bosh --version && echo
echo "Cloud Foundry CLI" && cf --version && echo
echo "Credhub CLI" && credhub --version && echo
echo "curl" && curl --version && echo
echo "Google Cloud SDK" && gcloud version && echo
echo "Github CLI" && gh version && echo
echo "git" && git --version && echo
echo "Go" && go version && echo
echo "Helm" && helm version && echo
echo "Helm File" && helmfile version && echo
echo "HTTPie" && http --version && echo
echo "Carvel imgpkg" && imgpkg version && echo
echo "Java" && java --version && echo
echo "JSON Query (jq)" && jq --version && echo
echo "K9s" && k9s version && echo
echo "Carvel kapp" && kapp version && echo
echo "Carvel kwt" && kwt version && echo
echo "Krew, the package manager for kubectl plugins" && krew version && echo
echo "kubectl" && kubectl version && echo
echo "mkcert" && mkcert --version && echo
echo "VMware Tanzu Ops Manager CLI" && om version && echo
echo "Open SSL" && openssl version && echo
echo "Oracle Cloud Infrastructure CLI" && oci --version && echo
echo "Node JS" && node --version && echo
echo "Node Package Manager" && npm version && echo
echo "Cloud Native Buildpacks CLI" && pack --version && echo
echo "Tanzu Network CLI" && pivnet version && echo
echo "Tekton CD CLI" && tkn version && echo
echo "Hashicorp Terraform CLI" && terraform version && echo
echo "Public Cloud Resources Clean-up Utility (leftovers)" && leftovers --version && echo
echo "Tanzu CLI" && tanzu version && echo
echo "Tanzu Mission Control CLI" && tmc version && echo
echo "CloudFoundry UAA CLI" && uaac --version && echo
echo "Carvel vendir" && vendir version && echo
echo "Carvel ytt" && ytt version && echo
echo "wget" && wget --version && echo
