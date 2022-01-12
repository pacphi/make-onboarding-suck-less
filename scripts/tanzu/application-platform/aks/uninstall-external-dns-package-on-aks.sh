#!/bin/bash
set -e

# Remove external-dns

## Uninstall Tanzu package
tanzu package installed delete external-dns -n tanzu-package-repo-global -y

## Delete all resources with target namespace including the namespace
kubectl delete ns tanzu-system-service-discovery

# Delete dangling resources
kubectl delete sa external-dns-tanzu-package-repo-global-sa -n tanzu-package-repo-global
kubectl delete clusterroles.rbac.authorization.k8s.io external-dns-tanzu-package-repo-global-cluster-role
kubectl delete clusterrolebindings.rbac.authorization.k8s.io external-dns-tanzu-package-repo-global-cluster-rolebinding
