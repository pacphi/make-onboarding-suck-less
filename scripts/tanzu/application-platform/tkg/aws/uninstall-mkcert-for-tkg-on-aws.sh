#!/bin/bash
set -e

# Remove mkcert managed Certificate plus Secret and ClusterIssuer

## Delete ClusterIssuer
kubectl delete clusterissuer ca-issuer -n cert-manager

## Delete Certificate
kubectl delete cert tls -n contour-tls

## Delete Secrets
kubectl delete secret route53-credentials-secret -n cert-manager
kubectl delete secret ca-key-pair -n cert-manager
kubectl delete secret tls -n contour-tls
kubectl delete secret tls -n learningcenter

## Uninstall EmberStack's Reflector
kubectl -n kube-system delete -f https://github.com/emberstack/kubernetes-reflector/releases/download/v6.0.42/reflector.yaml

## Delete namespace
kubectl delete namespace contour-tls
