# Tanzu Application Platform Quickstart Guide

## Create a new workload cluster

```
cat > zoolabs-tap.yml <<EOF
CLUSTER_NAME: zoolabs-tap
CLUSTER_PLAN: dev
NAMESPACE: default
CNI: antrea
IDENTITY_MANAGEMENT_TYPE: none
CONTROL_PLANE_MACHINE_TYPE: t3.large
NODE_MACHINE_TYPE: m5.xlarge
AWS_REGION: "us-west-2"
AWS_NODE_AZ: "us-west-2b"
AWS_SSH_KEY_NAME: "se-cphillipson-cloudgate-aws-us-west-2"
BASTION_HOST_ENABLED: false
ENABLE_MHC: true
MHC_UNKNOWN_STATUS_TIMEOUT: 5m
MHC_FALSE_STATUS_TIMEOUT: 12m
ENABLE_AUDIT_LOGGING: false
ENABLE_DEFAULT_STORAGE_CLASS: true
CLUSTER_CIDR: 100.96.0.0/11
SERVICE_CIDR: 100.64.0.0/13
ENABLE_AUTOSCALER: false
EOF

tanzu cluster create --file zoolabs-tap.yml

tanzu cluster scale zoolabs-tap --worker-machine-count 3
```
> Replace occurrences of `zoolabs-tap` above with whatever name you'd like to give the workload cluster.  You'll also want to replace the value of `AWS_SSH_KEY_NAME` with your own SSH key.  Other property values may be updated as appropriate.


Obtain the new workload cluster kubectl configuration.

```
tanzu cluster kubeconfig get zoolabs-tap --admin
```
> Replace occurrence of `zoolabs-tap` above with name you gave the workload cluster.

Sample output

```
Credentials of cluster 'zoolabs-tap' have been saved
You can now access the cluster by running 'kubectl config use-context zoolabs-tap-admin@zoolabs-tap'
```

## Upgrade kapp-controller

### Verify installed version

```
kubectl get deployment kapp-controller -n tkg-system -o yaml | grep kapp-controller.carvel.dev/version
```
> You should see version 0.23.0 if you've installed Tanzu Kubernetes Grid 1.4 or Tanzu Community Edition.  We need to delete this version and install a newer version of the kapp-controller.

### Install newer version

Log into management cluster

```
kubectl config use-context zoolabs-mgmt-admin@zoolabs-mgmt
```
> Replace `zoolabs-mgmt` with your own management cluster name.

Apply this patch

```
kubectl patch app/zoolabs-tap-kapp-controller -n default -p '{"spec":{"paused":true}}' --type=merge
```
> Replace `zoolabs-tap` with your own workload cluster name.

Login to workload cluster, teardown the existing kapp-controller deployment, and deploy a new version of kapp-controller.

```
kubectl config use-context zoolabs-tap-admin@zoolabs-tap
kubectl delete deployment kapp-controller -n tkg-system
kubectl apply -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/download/v0.29.0/release.yml
```
> Replace occurrence of `zoolabs-tap-admin@zoolabs-tap` with your own workload cluster context.


### Verify new release version installed

```
kubectl get deployment kapp-controller -n kapp-controller -o yaml | grep kapp-controller.carvel.dev/version
```

## Install secret-gen-controller

```
kapp deploy -y -a sg -f https://github.com/vmware-tanzu/carvel-secretgen-controller/releases/download/v0.6.0/release.yml
```

Verify install

```
kubectl get deployment secretgen-controller -n secretgen-controller -o yaml | grep secretgen-controller.carvel.dev/version
```

## Add the Tanzu Application Platform specific plugins

> This procedure expects that you want to maintain the Tanzu CLI core and plugins you installed previously for interacting with Tanzu Kubernetes Grid or Tanzu Community Edition.

You'll want to copy and save the contents of the [install-tap-plugins.sh](install-tap-plugins.sh) to the machine where you had previously installed and used the `tanzu` CLI.

```
./install-tap-plugins.sh {tanzu-network-api-token}
```
> Replace `{tanzu-network-api-token}` with a valid VMWare Tanzu Network [API Token](https://network.pivotal.io/users/dashboard/edit-profile)

## Add the Tanzu Application Platform Package Repository

Create a new namespace

```
kubectl create ns tap-install
```

Create a registry secret

```
tanzu secret registry add tap-registry \
  --username "{tanzu-network-username}" --password "{tanzu-network-password}" \
  --server registry.tanzu.vmware.com \
  --export-to-all-namespaces --yes --namespace tap-install
```
> Replace `{tanzu-network-username}` and `{tanzu-network-password}` with the account credentials that you use to authenticate to the VMware Tanzu Network.


Add Tanzu Application Platform package repository to the cluster by running:

```
tanzu package repository add tanzu-tap-repository \
  --url registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:0.3.0-build.5 \
  --namespace tap-install
```

Get the status of the Tanzu Application Platform package repository, and ensure the status updates to Reconcile succeeded by running:

```
tanzu package repository get tanzu-tap-repository --namespace tap-install
```

List the available packages by running:

```
tanzu package available list --namespace tap-install
```

## Install a Tanzu Application Platform Profile

To view possible configuration settings, run:

```
tanzu package available get tap.tanzu.vmware.com/0.3.0-build.5 --values-schema --namespace tap-install
```
> Note that currently that the `tap.tanzu.vmware.com` package does not show all configuration settings for packages it plans to install. To find them out, look at the individual package configuration settings via same `tanzu package available get` command (e.g. for CNRs use `tanzu package available get -n tap-install cnrs.tanzu.vmware.com/1.0.3 --values-schema`). Replace dashes with underscores. For example, if the package name is `cloud-native-runtimes`, use `cloud_native_runtimes` in the `tap-values` YAML file.

Let's create a sample tap-value.yml file:

```
cat > tap-values.yml << EOF
profile: full
buildservice:
  tanzunet_username: "{tanzu-network-username}"
  tanzunet_password: "{tanzu-network-password}"
rw_app_registry:
  server_repo: "{container-registry-domain}/apps"
  username: "{container-registry-username}"
  password: "{container-registry-password}"
ootb_supply_chain_basic:
  service_account: service-account
learning_center:
  ingressDomain: "educates.{domain}"
EOF
```
> Replace curly-bracketed value-placeholders with real values.

Install the package by running:

```
tanzu package install tap -p tap.tanzu.vmware.com -v 0.3.0-build.5 --values-file tap-values.yml -n tap-install
```

Verify the package install by running:

```
tanzu package installed get tap -n tap-install
```

Verify all the necessary packages in the profile are installed by running:

```
tanzu package installed list -A
```
