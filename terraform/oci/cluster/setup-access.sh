#!/usr/bin/env bash#!/bin/bash

if [ -z "$1" ] && [ -z "$2" ]; then
	echo "Usage: setup-access.sh {user-ocid} {region}"
	exit 1
fi

USER_OCID="$1"
REGION="$2"

echo "Setting up access to cluster"
oci ce cluster create-kubeconfig --cluster-id $(tf output cluster-ocid | tr -d '"') --file $HOME/.kube/config  --region ${REGION} --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT
