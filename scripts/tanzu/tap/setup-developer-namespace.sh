#!/bin/bash

if [ -z "$1" ] && [ -z "$2" ] && [ -z "$3" ] && [ -z "$4" ]; then
	echo "Usage: setup-developer-namespace.sh {registry-server} {registry-username} {registry-password} {namespace}"
	exit 1
fi

export REGISTRY_SERVER="$1"
export REGISTRY_USERNAME="$2"
export REGISTRY_PASSWORD="$3"
export NAMESPACE="${4:default}"

## Create namespace

kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

## Add secret for container image registry access

tanzu secret registry add registry-credentials --server ${REGISTRY_SERVER} --username ${REGISTRY_USERNAME} --password "${REGISTRY_PASSWORD}" --namespace ${NAMESPACE}

## Add placeholder read secrets, a service account, and RBAC rules to the developer namespace

cat <<EOF | kubectl -n ${NAMESPACE} apply -f -

apiVersion: v1
kind: Secret
metadata:
  name: tap-registry
  annotations:
    secretgen.carvel.dev/image-pull-secret: ""
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: e30K

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: default
secrets:
  - name: registry-credentials
imagePullSecrets:
  - name: registry-credentials
  - name: tap-registry

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: kapp-permissions
  annotations:
    kapp.k14s.io/change-group: "role"
rules:
  - apiGroups:
      - servicebinding.io
    resources: ['servicebindings']
    verbs: ['*']
  - apiGroups:
      - services.tanzu.vmware.com
    resources: ['resourceclaims']
    verbs: ['*']
  - apiGroups:
      - serving.knative.dev
    resources: ['services']
    verbs: ['*']
  - apiGroups: [""]
    resources: ['configmaps']
    verbs: ['get', 'watch', 'list', 'create', 'update', 'patch', 'delete']

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: kapp-permissions
  annotations:
    kapp.k14s.io/change-rule: "upsert after upserting role"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: kapp-permissions
subjects:
  - kind: ServiceAccount
    name: default

EOF