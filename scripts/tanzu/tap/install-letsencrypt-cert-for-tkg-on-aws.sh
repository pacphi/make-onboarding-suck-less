#!/bin/bash
set -e

# Automates wildcard ClusterIssuer, Certificate and Secret generation on a TKG cluster on AWS where cert-manager is already installed.

if [ -z "$1" ] && [ -z "$2" ] && [ -z "$3" ] && [ -z "$4" ] && [ -z "$5" ] && [ -z "$6" ]; then
	echo "Usage: install-letsencypt-cert-for-tkg-on-aws.sh {email-address} {aws-access-key-id} {aws-secret-access-key} {aws-region} {domain} {hosted-zone-id}"
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

kubectl -n kube-system apply -f https://github.com/emberstack/kubernetes-reflector/releases/download/v6.0.21/reflector.yaml

## Create the certificate in the contour-external namespace
cat << EOF | tee knative-tls.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: knative-tls
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
    name: letsencrypt-prod
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

