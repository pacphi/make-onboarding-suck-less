#!/bin/bash
set -e

# Borrowed from https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/oracle.md

# Function to indent each line of multi-line string 4 spaces
indent() { sed 's/^/    /'; }

if [ -z "$1" ] && [ -z "$2" ] && [ -z "$3" ] && [ -z "$4" ] && [ -z "$5" ] && [ -z "$6" ] && [ -z "$7" ]; then
	echo "Usage: install-external-dns-package-on-oci.sh {region} {tenancy_ocid} {user_ocid} {path_to_oci_api_key_pem_file} {fingerprint} {compartment_ocid} {domain}"
	exit 1
fi

export REGION="$1"
export TENANCY_OCID="$2"
export USER_OCID="$3"
export OCI_API_PK="$(cat $4 | indent)"
export FINGERPRINT="$5"
export COMPARTMENT_OCID="$6"
export DOMAIN="$7"


kubectl create ns tanzu-system-service-discovery

## Create oci.yaml

cat > oci.yaml <<EOF
auth:
  region: ${REGION}
  tenancy: ${TENANCY_OCID}
  user: ${USER_OCID}
  key: |
${OCI_API_PK}
  fingerprint: ${FINGERPRINT}
compartment: ${COMPARTMENT_OCID}
EOF

## Create secret
kubectl -n tanzu-system-service-discovery create secret generic external-dns-admin-credentials \
  --from-file=oci.yaml

cat > external-dns-data-values.yaml <<EOF
---

# Namespace in which to deploy ExternalDNS.
namespace: tanzu-system-service-discovery

# Deployment-related configuration.
deployment:
  args:
  - --source=service
  - --source=ingress
  - --source=contour-httpproxy # Provide this to enable Contour HTTPProxy support. Must have Contour installed or ExternalDNS will fail.
  - --domain-filter=${DOMAIN} # Makes ExternalDNS see only the hosted zones matching provided domain, omit to process all available hosted zones.
  - --policy=upsert-only # Prevents ExternalDNS from deleting any records, omit to enable full synchronization.
  - --registry=txt
  - --txt-owner-id=external-dns
  - --txt-prefix=txt # Disambiguates TXT records from CNAME records.
  - --provider=oci
  securityContext: {}
  volumeMounts:
  - mountPath: /etc/kubernetes/
    name: config
    readOnly: true
  volumes:
  - name: config
    secret:
      secretName: external-dns-admin-credentials
EOF

## Remove --domain-filter when DOMAIN is set to "-"
if [ "-" == "${DOMAIN}" ]; then
  sed -i '12d' external-dns-data-values.yaml
fi

tanzu package install external-dns -p external-dns.tanzu.vmware.com -v 0.8.0+vmware.1-tkg.1 --values-file external-dns-data-values.yaml -n tanzu-package-repo-global
