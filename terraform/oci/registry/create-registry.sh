#!/bin/bash

terraform init
terraform validate
terraform graph | dot -Tsvg > graph.svg
terraform plan -out terraform.plan
terraform apply -auto-approve -state terraform.tfstate terraform.plan

echo "Please consult https://docs.oracle.com/en-us/iaas/Content/Registry/Tasks/registrypushingimagesusingthedockercli.htm in order to create and use an Auth Token with this repository."
