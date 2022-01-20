#!/bin/bash

set -e

# Automates wildcard ClusterIssuer, Certificate and Secret generation on a OCI cluster where cert-manager is already installed.

if [ -z "$1" ]; then
	echo "Usage: install-smallstep-cert-on-oci.sh {domain}"
	exit 1
fi

DOMAIN="$1"

## Install step-certificates and step-issuer Helm charts

helm repo add smallstep  https://smallstep.github.io/helm-charts
helm repo update
helm install step-certificates smallstep/step-certificates
helm install step-issuer smallstep/step-issuer

## Get step-certificates root certificate

ROOT_CERT=$(kubectl get -o jsonpath="{.data['root_ca\.crt']}" configmaps/step-certificates-certs | base64 -w0)

## Get the step-certificate provisioner information

PROVISIONER_INFO=$(kubectl get -o jsonpath="{.data['ca\.json']}" configmaps/step-certificates-config | jq .authority.provisioners)
KID=$(echo "${PROVISIONER_INFO}" | jq  '.[0].key.kid' | tr -d '"')

## Create StepClusterIssuer

cat > step-cluster-issuer.yaml <<EOF
---
apiVersion: certmanager.step.sm/v1beta1
kind: StepClusterIssuer
metadata:
  name: step-cluster-issuer
  namespace: default
spec:
  url: https://step-certificates.default.svc.cluster.local
  caBundle: ${ROOT_CERT}
  provisioner:
    name: admin
    kid: ${KID}
    passwordRef:
      namespace: default
      name: step-certificates-provisioner-password
      key: password
EOF


## Install EmberStack's Reflector
### Reflector can create mirrors (of configmaps and secrets) with the same name in other namespaces automatically

kubectl -n kube-system apply -f https://github.com/emberstack/kubernetes-reflector/releases/download/v6.0.42/reflector.yaml

# Create namespace
kubectl create ns contour-tls

# Create TLSCertificateDelegation
cat << EOF | tee tls-cert-delegation.yaml
apiVersion: projectcontour.io/v1
kind: TLSCertificateDelegation
metadata:
  name: contour-delegation
  namespace: contour-tls
spec:
  delegations:
    - secretName: tls
      targetNamespaces:
        - "*"
EOF

kubectl apply -f tls-cert-delegation.yaml

# Expose API Portal
## As of tap-beta4 there is no set of configuration options to do this via tap-values.yaml
cat << EOF | tee api-portal-proxy.yaml
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: api-portal-external
  namespace: api-portal
spec:
  routes:
  - conditions:
    - prefix: /
    services:
    - name: api-portal-server
      port: 8080
  virtualhost:
    fqdn: "api-portal.${DOMAIN}"
    tls:
      secretName: contour-tls/tls
EOF

kubectl apply -f api-portal-proxy.yaml

## Create the certificate in the contour-tls namespace
cat << EOF | tee tls.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: tls
  namespace: contour-tls
spec:
  secretTemplate:
    annotations:
      reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true"
      reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
      reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "learningcenter"
  secretName: tls
  commonName: "*.${DOMAIN}"
  dnsNames:
  - "*.${DOMAIN}"
  duration: 24h
  renewBefore: 8h
  issuerRef:
    group: certmanager.step.sm
    kind: StepClusterIssuer
    name: step-cluster-issuer
EOF

kubectl apply -f step-cluster-issuer.yaml
kubectl apply -f tls.yaml

echo "Waiting..."
sleep 1m 30s

## If the above worked, you should get back a secret name starting with tls in the contour-tls namespace.  We should also see that the challenge succeeded (i.e., there should be no challenges in the namespace).
## Let's verify...

kubectl get secret -n contour-tls | grep tls
kubectl describe challenges -n contour-tls
