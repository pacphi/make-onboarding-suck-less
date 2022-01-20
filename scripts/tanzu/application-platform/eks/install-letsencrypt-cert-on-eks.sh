#!/bin/bash
set -e

# Automates wildcard ClusterIssuer, Certificate and Secret generation on a TKG cluster on AWS where cert-manager is already installed.

if [ -z "$1" ] && [ -z "$2" ] && [ -z "$3" ] && [ -z "$4" ] && [ -z "$5" ] && [ -z "$6" ]; then
	echo "Usage: install-letsencypt-cert-on-eks.sh {email-address} {aws-access-key-id} {aws-secret-access-key} {aws-region} {domain} {hosted-zone-id}"
	exit 1
fi

export EMAIL_ADDRESS="$1"
export AWS_ACCESS_KEY_ID="$2"
export AWS_SECRET_ACCESS_KEY="$3"
export AWS_REGION="$4"
export DOMAIN="$5"
export HOSTED_ZONE_ID="$6"

## Create secret for AWS_SECRET_ACCESS_KEY
kubectl -n cert-manager create secret generic route53-credentials-secret \
  --from-literal=aws-secret-access-key=${AWS_SECRET_ACCESS_KEY}

## Create the cluster issuer
cat << EOF | tee cluster-issuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
  namespace: cert-manager
spec:
  acme:
    email: "${EMAIL_ADDRESS}"
    privateKeySecretRef:
      name: letsencrypt-prod
    server: https://acme-v02.api.letsencrypt.org/directory
    solvers:
    - dns01:
        route53:
          region: ${AWS_REGION}
          hostedZoneID: ${HOSTED_ZONE_ID}
          accessKeyID: ${AWS_ACCESS_KEY_ID}
          # The following is the secret we created in Kubernetes. Issuer will use this to present challenge to AWS Route53.
          secretAccessKeySecretRef:
            name: route53-credentials-secret
            key: aws-secret-access-key
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
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
EOF


kubectl apply -f cluster-issuer.yaml
kubectl apply -f tls.yaml

echo "Waiting..."
sleep 2m 30s

## If the above worked, you should get back a secret name starting with tls in the contour-tls namespace.  We should also see that the challenge succeeded (i.e., there should be no challenges in the namespace).
## Let's verify...

kubectl get secret -n contour-tls | grep tls
kubectl describe challenges -n contour-tls