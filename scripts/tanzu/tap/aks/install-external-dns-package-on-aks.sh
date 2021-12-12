#!/bin/bash
set -e

if [ -z "$1" ] && [ -z "$2" ] && [ -z "$3" ]; then
	echo "Usage: install-external-dns-package-on-gke.sh {project-id} {service-account-key-path-to-file-in-json-format} {domain}"
	exit 1
fi

export PROJECT_ID="$1"
export SERVICE_ACCOUNT_KEY_FILE="$2"
export DOMAIN="$3"

kubectl create ns tanzu-system-service-discovery

## Create secret for SERVICE_ACCOUNT_KEY_FILE
kubectl -n tanzu-system-service-discovery create secret generic external-dns-admin-credentials \
  --from-literal=credentials.json="$(cat ${SERVICE_ACCOUNT_KEY_FILE})"

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
   - --domain-filter=DOMAIN # For example, k8s.example.org. Makes ExternalDNS see only the hosted zones matching provided domain, omit to process all available hosted zones.
   - --policy=upsert-only # Prevents ExternalDNS from deleting any records, omit to enable full synchronization.
   - --registry=txt
   - --txt-prefix=externaldns- # Disambiguates TXT records from CNAME records.
   - --provider=azure
   - --azure-resource-group=RESOURCE-GROUP # Azure resource group.
 env: []
 securityContext: {}
 volumeMounts:
   - name: azure-config-file
     mountPath: /etc/kubernetes
     readOnly: true
 volumes:
   - name: azure-config-file
     secret:
       secretName: azure-config-file
EOF

tanzu package install external-dns -p external-dns.tanzu.vmware.com -v 0.8.0+vmware.1-tkg.1 --values-file external-dns-data-values.yaml -n tanzu-package-repo-global
