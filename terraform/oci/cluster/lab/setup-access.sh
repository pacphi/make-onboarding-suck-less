#!/usr/bin/env bash

if [ -z "$1" ]; then
	echo "Usage: setup-access.sh {region}"
	exit 1
fi

REGION="$1"

# @see https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengdownloadkubeconfigfile.htm#Setting_Up_Cluster_Access
echo "Setting up access to cluster"
oci ce cluster create-kubeconfig --cluster-id $(terraform output cluster-ocid | tr -d '"') --file $HOME/.kube/config  --region ${REGION} --token-version 2.0.0
