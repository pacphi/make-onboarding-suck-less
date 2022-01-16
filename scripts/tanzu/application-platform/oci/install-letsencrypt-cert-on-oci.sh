#!/bin/bash
set -e

# Function to indent each line of multi-line string 4 spaces
indent() { sed 's/^/    /'; }

if ! command -v lego &> /dev/null
then
  echo "Downloading lego CLI..."
	curl -LO curl -LO https://github.com/go-acme/lego/releases/download/v4.5.3/lego_v4.5.3_linux_386.tar.gz
	tar xvf lego_v4.5.3_linux_386.tar.gz
  rm -f CHANGELOG.md LICENSE
	sudo mv lego /usr/local/bin
fi

# Automates wildcard ClusterIssuer, Certificate and Secret generation on a OCI cluster where cert-manager is already installed.

if [ -z "$1" ] && [ -z "$2" ] && [ -z "$3" ] && [ -z "$4" ] && [ -z "$5" ] && [ -z "$6" ] && [ -z "$7" ] && [ -z "$8" ]; then
	echo "Usage: install-letsencypt-cert-on-oci.sh {region} {tenancy_ocid} {user_ocid} {path_to_oci_api_key_pem_file} {fingerprint} {compartment_ocid} {domain} {email-address}"
	exit 1
fi

export OCI_REGION="$1"
export OCI_TENANCY_OCID="$2"
export OCI_USER_OCID="$3"
export OCI_PRIVKEY_FILE="$4"
export OCI_PRIVKEY_PASS=""
export OCI_PUBKEY_FINGERPRINT="$5"
export OCI_COMPARTMENT_OCID="$6"
export DOMAIN="$7"
export EMAIL_ADDRESS="$8"


# Fetch cert and private key
## @see https://go-acme.github.io/lego/dns/oraclecloud/

export OCI_POLLING_INTERVAL=120
export OCI_PROPAGATION_TIMEOUT=900
export OCI_TTL=900

lego --email ${EMAIL_ADDRESS} --dns oraclecloud --domains *.${DOMAIN} --accept-tos run

TLS_CRT="$(cat .lego/certificates/_.${DOMAIN}.issuer.crt | base64 -w 0)"
TLS_KEY="$(cat .lego/certificates/_.${DOMAIN}.key | base64 -w 0)"


## Create secret

cat > oci-profile-secret.yml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ca-key-pair
  namespace: cert-manager
data:
  tls.crt: ${TLS_CRT}
  tls.key: ${TLS_KEY}
EOF

kubectl apply -f oci-profile-secret.yml -n cert-manager

## Create the cluster issuer
cat << EOF | tee cluster-issuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-issuer
  namespace: cert-manager
spec:
  ca:
    secretName: ca-key-pair
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
    name: ca-issuer
    kind: ClusterIssuer
EOF


kubectl apply -f cluster-issuer.yaml
kubectl apply -f tls.yaml

echo "Waiting..."
sleep 1m 30s

## If the above worked, you should get back a secret name starting with tls in the contour-tls namespace.  We should also see that the challenge succeeded (i.e., there should be no challenges in the namespace).
## Let's verify...

kubectl get secret -n contour-tls | grep tls
kubectl describe challenges -n contour-tls
