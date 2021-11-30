#!/bin/bash

if [ -z "$1" ] && [ -z "$2" ]; then
	echo "Usage: set-kubectl-context.sh <gke-cluster-name> <gke-zone>"
	exit 1
fi

gcloud container clusters get-credentials "$1" --zone "$2"