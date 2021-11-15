#!/bin/bash
set -e

# Remove mkcert managed Certificate plus Secret and ClusterIssuer

## Delete ClusterIssuer
kubectl delete clusterissuer mkcert -n cert-manager

## Delete Certificate
kubectl delete cert knative-tls -n contour-external

## Delete Secrets
kubectl delete secret mkcert-secret -n cert-manager
kubectl delete secret knative-tls -n contour-external
kubectl delete secret knative-tls -n educates

## Uninstall EmberStack's Reflector
kubectl -n kube-system delete -f https://github.com/emberstack/kubernetes-reflector/releases/download/v6.0.21/reflector.yaml
