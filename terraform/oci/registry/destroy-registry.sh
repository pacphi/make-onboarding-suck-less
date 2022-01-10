#!/bin/bash

#
#terraform destroy -auto-approve
#rm -Rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup terraform.log terraform.plan graph.svg


if [ -z "$1" ]; then
  echo "Usage: destroy-registry.sh {repository-ocid}"
  exit 1
fi

REPOSITORY_OCID="$1"

oci artifacts container repository delete --repository-id ${REPOSITORY_OCID} --force
