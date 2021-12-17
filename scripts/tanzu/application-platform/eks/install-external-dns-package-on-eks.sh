#!/bin/bash
set -e

if [ -z "$1" ] && [ -z "$2" ] && [ -z "$3" ] && [ -z "$4" ]; then
	echo "Usage: install-external-dns-package-on-eks.sh {aws-access-key-id} {aws-secret-access-key} {domain} {hosted-zone-id}"
	exit 1
fi

export AWS_ACCESS_KEY_ID="$1"
export AWS_SECRET_ACCESS_KEY="$2"
export DOMAIN="$3"
export HOSTED_ZONE_ID="$4"

kubectl create ns tanzu-system-service-discovery
kubectl -n tanzu-system-service-discovery create secret generic route53-credentials \
  --from-literal=aws_access_key_id=${AWS_ACCESS_KEY_ID} \
  --from-literal=aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}

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
   - --txt-owner-id=${HOSTED_ZONE_ID}
   - --txt-prefix=txt # Disambiguates TXT records from CNAME records.
   - --provider=aws
   - --aws-zone-type=public # Looks only at public hosted zones. Valid values are public, private, or no value for both.
   - --aws-prefer-cname
 env:
   - name: AWS_ACCESS_KEY_ID
     valueFrom:
       secretKeyRef:
         name: route53-credentials
         key: aws_access_key_id
   - name: AWS_SECRET_ACCESS_KEY
     valueFrom:
       secretKeyRef:
         name: route53-credentials
         key: aws_secret_access_key
 securityContext: {}
 volumeMounts: []
 volumes: []
EOF

tanzu package install external-dns -p external-dns.tanzu.vmware.com -v 0.8.0+vmware.1-tkg.1 --values-file external-dns-data-values.yaml -n tanzu-package-repo-global
