#!/bin/bash

if [ -z "$1" ] && [ -z "$2" ]; then
	echo "Usage: set-kubectl-context.sh <aks-cluster-name> <azure-resource-group>"
	exit 1
fi

az aks get-credentials --admin --name "$1" --resource-group "$2"
