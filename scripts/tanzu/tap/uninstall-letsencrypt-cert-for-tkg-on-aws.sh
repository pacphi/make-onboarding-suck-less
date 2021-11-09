#!/usr/bin env bash
set -e

# Remove Let's Encrypt managed Certificate plus Secret and ClusterIssuer

## Delete ClusterIssuer
kubectl delete clusterissuer letsencrypt-prod -n cert-manager

## Delete Certificate
kubectl delete cert knative-tls -n contour-external

## Delete Secrets
kubectl delete secret route53-credentials-secret -n cert-manager
kubectl delete secret letsencrypt-prod -n cert-manager