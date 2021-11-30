#!/usr/bin/env bash

# @author Chris Phillipson
# @version 1.0

# Prerequisities:
## - *nix OS
## - Public Internet access
## - Cloud provider CLI installed (e.g., aws, az, gcloud)
## - Cloud provider account admin credentials in addition to storage account credentials
## - Pre-authenticated with cloud provider account admin credentials

source $PWD/iam-config.sh

# Authenticate, create service account, enable bucket versioning
case "$IAAS" in
  aws)
      export AWS_PAGER=""
      # Thanks to https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html and https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html
      aws configure
      aws iam create-group --group-name Admins
      aws iam attach-group-policy --group-name Admins --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
      aws iam create-user –-user-name $AWS_SERVICE_ACCOUNT
      aws create-login-profile --username $AWS_SERVICE_ACCOUNT --password $AWS_SERVICE_ACCOUNT_PASSWORD --no-password-reset-required true
      aws iam add-user-to-group --user-name $AWS_SERVICE_ACCOUNT --group-name Admins
      aws iam create-access-key --user-name $AWS_SERVICE_ACCOUNT > key.txt
      AWS_ACCESS_KEY=$(cat key.txt | jq -r ".AccessKey.AccessKeyId")
      AWS_SECRET_KEY=$(cat key.txt | jq -r ".AccessKey.SecretAccessKey")
      rm -rf key.txt

      ;;

  azure)
      # Thanks to https://markheath.net/post/create-service-principal-azure-cli
      az login
      az account set -s $AZ_SUBSCRIPTION_ID
      az ad app create --display-name $AZ_APP_NAME --homepage "http://localhost/$AZ_APP_NAME"
      AZ_APP_ID=$(az ad app list --display-name $AZ_APP_NAME | jq '.[0].appId' | tr -d '"')
      az ad sp create-for-rbac --name $AZ_APP_ID --role="Contributor" --scopes="/subscriptions/$AZ_SUBSCRIPTION_ID/resourceGroups/$AZ_RESOURCE_GROUP"
      az ad sp credential reset --name "$AZ_APP_ID" --password "${AZ_CLIENT_SECRET}"
      AZ_CLIENT_ID=$(az ad sp list --display-name $AZ_APP_ID | jq '.[0].appId' | tr -d '"')
      # @see https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-cli
      az role assignment create --assignee "$AZ_CLIENT_ID" --role "Owner" --subscription "$AZ_SUBSCRIPTION_ID"

      az storage account create -n $AZ_STORAGE_ACCOUNT_NAME -g $AZ_RESOURCE_GROUP -l $AZ_REGION --sku Standard_LRS
      az storage account blob-service-properties update --enable-versioning -n $AZ_STORAGE_ACCOUNT_NAME -g $AZ_RESOURCE_GROUP
      ;;

  gcp)
      gcloud auth login
      gcloud iam service-accounts create $GCP_SERVICE_ACCOUNT
      gcloud projects add-iam-policy-binding $GCP_PROJECT --member="serviceAccount:$GCP_SERVICE_ACCOUNT@$GCP_PROJECT.iam.gserviceaccount.com" --role="roles/owner"
      gcloud iam service-accounts keys create $GCP_SERVICE_ACCOUNT.$GCP_PROJECT.json --iam-account=$GCP_SERVICE_ACCOUNT@$GCP_PROJECT.iam.gserviceaccount.com
      ;;

  *)
      echo -e "IAAS must be set to one of [ aws, azure, gcp ]"
      exit 1
esac