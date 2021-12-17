#!/bin/bash
set -e

# Remove Let's Encrypt managed Certificate plus Secret and ClusterIssuer

## Delete ClusterIssuer
kubectl delete clusterissuer letsencrypt-prod -n cert-manager

## Delete Certificate
kubectl delete cert harbor-tls-le -n tanzu-system-registry

## Delete Secrets
kubectl delete secret route53-credentials-secret -n cert-manager
kubectl delete secret letsencrypt-prod -n cert-manager
kubectl delete secret harbor-tls-le -n tanzu-system-registry
