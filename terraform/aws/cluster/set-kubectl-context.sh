#!/bin/bash

if [ -z "$1" ] && [ -z "$2" ]; then
	echo "Usage: set-kubectl-context.sh <aws-region> <eks-cluster-name>"
	exit 1
fi

aws eks --region "$1" update-kubeconfig --name "$2"
