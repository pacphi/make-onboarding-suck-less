#!/bin/bash

#
#terraform init
#terraform validate
#terraform graph | dot -Tsvg > graph.svg
#terraform plan -out terraform.plan
#terraform apply -auto-approve -state terraform.tfstate terraform.plan

if [ -z "$1" ] && [ -z "$2" ]; then
  echo "Usage: create-registry.sh {compartment-ocid} {repository-name}"
  exit 1
fi

COMPARTMENT_OCID="$1"
REPOSITORY_NAME="$2"

oci artifacts container repository create --compartment-id ${COMPARTMENT_OCID} --display-name ${REPOSITORY_NAME}

echo "Please consult https://docs.oracle.com/en-us/iaas/Content/Registry/Tasks/registrypushingimagesusingthedockercli.htm in order to create and use an Auth Token with this repository."
