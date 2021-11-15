#!/bin/bash
set -e

# Automates wildcard ClusterIssuer, Certificate and Secret generation on a TKG cluster where cert-manager is already installed.

if [ -z "$1" ] && [ -z "$2" ] && [ -z "$3" ]; then
	echo "Usage: install-mkcert-for-tkg-on-aws.sh {domain} {path-to-cert-pem-filename} {path-to-key-pem-filename}"
	exit 1
fi

export DOMAIN="$1"
export CERT_PEM_FILE="$2"
export KEY_PEM_FILE="$3"


## Create secret with existing CA and private key generated by mkcert
## This secret should be the same as the one you used with cluster provisioning and with container image regsitry (Harbor)

kubectl create secret tls mkcert-secret \
  --cert="${CERT_PEM_FILE}" \
  --key="${KEY_PEM_FILE}" \
  --namespace cert-manager

## Create the cluster issuer
cat << EOF | tee cluster-issuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: mkcert
  namespace: cert-manager
spec:
  ca:
    secretName: mkcert-secret
EOF

## Install EmberStack's Reflector
### Reflector can create mirrors (of configmaps and secrets) with the same name in other namespaces automatically

kubectl -n kube-system apply -f https://github.com/emberstack/kubernetes-reflector/releases/download/v6.0.21/reflector.yaml

## Create the certificate in the contour-external namespace
cat << EOF | tee knative-tls.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: knative-cert
  namespace: contour-external
spec:
  secretTemplate:
    annotations:
      reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true"
      reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
      reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "educates"
  secretName: knative-tls
  commonName: "*.${DOMAIN}"
  dnsNames:
  - "*.${DOMAIN}"
  issuerRef:
    name: mkcert
    kind: ClusterIssuer
EOF


kubectl apply -f cluster-issuer.yaml
kubectl apply -f knative-tls.yaml

echo "Waiting..."
sleep 2m 30s

## If the above worked, you should get back a secret name starting with knative-tls in the contour-external namespace.  We should also see that the challenge succeeded (i.e., there should be no challenges in the namespace).
## Let's verify...

kubectl get secret -n contour-external | grep knative-tls
kubectl describe challenges -n contour-external

