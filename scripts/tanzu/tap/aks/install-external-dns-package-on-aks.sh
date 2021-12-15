#!/bin/bash
set -e

if [ -z "$1" ] && [ -z "$2" ] && [ -z "$3" ] && [ -z "$4" ] && [ -z "$5" ] && [ -z "$6" ]; then
	echo "Usage: install-external-dns-package-on-aks.sh {resource-group} {domain} {subscription-id} {tenant-id} {client-id} {client-secret}"
	exit 1
fi

export RESOURCE_GROUP="$1"
export DOMAIN="$2"
export SUBSCRIPTION_ID="$3"
export TENANT_ID="$4"
export CLIENT_ID="$5"
export CLIENT_SECRET="$6"

kubectl create ns tanzu-system-service-discovery

## Create secret based on Azure credentials (in JSON format)

cat > azure.json << EOF
{
 "tenantId": "${TENANT_ID}",
 "subscriptionId": "${SUBSCRIPTION_ID}",
 "resourceGroup": "${RESOURCE_GROUP}",
 "aadClientId": "${CLIENT_ID}",
 "aadClientSecret": "${CLIENT_SECRET}"
}
EOF

kubectl -n tanzu-system-service-discovery create secret generic azure-config-file --from-file=azure.json

## Configure the package

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
   - --domain-filter=${DOMAIN} # For example, k8s.example.org. Makes ExternalDNS see only the hosted zones matching provided domain, omit to process all available hosted zones.
   - --policy=upsert-only # Prevents ExternalDNS from deleting any records, omit to enable full synchronization.
   - --registry=txt
   - --txt-prefix=externaldns- # Disambiguates TXT records from CNAME records.
   - --provider=azure
   - --azure-resource-group=${RESOURCE_GROUP} # Azure resource group.
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
