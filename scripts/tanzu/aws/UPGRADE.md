# Upgrade Tanzu Kubernetes Grid Cluster

## From 1.3.1 to 1.4.0

### Deregister management cluster from TMC

```
tmc mc deregister {MANAGEMENT_CLUSTER_NAME}
```
> Replace `{MANAGEMENT_CLUSTER_NAME}` with name of an existing registered management cluster with TMC

Sample interaction

```
ubuntu@ip-172-31-25-21:~$ tmc login
i If you don't have an API token, visit the VMware Cloud Services console, select your organization, and create an API token with the TMC service roles:
  https://console.cloud.vmware.com/csp/gateway/portal/#/user/tokens
? API Token ****************************************************************
? Login context name pacphi
? Select default log level info
? Management Cluster Name zoolabs-mgmt
? Provisioner Name pacphi
√ Successfully created context pacphi, to manage your contexts run `tmc system context -h`
ubuntu@ip-172-31-25-21:~$ tmc mc deregister zoolabs-mgmt
√ successfully de-registered management cluster in TMC
√ initiated clean up of TMC resources on cluster
```

### Restore the ~/.config/tanzu directory

Fetch .kube, .kube-tkg, and .tanzu directories from toolset jumpbox with Tanzu 1.3.1 CLI installed to workstation

```
scp -r -i {SSH_PRIVATE_KEY_PATH_TO_FILE} ubuntu@{EC2_INSTANCE_PUBLIC_NETWORK_ADDRESS}:/home/ubuntu/.kube dist
scp -r -i {SSH_PRIVATE_KEY_PATH_TO_FILE} ubuntu@{EC2_INSTANCE_PUBLIC_NETWORK_ADDRESS}:/home/ubuntu/.kube-tkg dist
scp -r -i {SSH_PRIVATE_KEY_PATH_TO_FILE} ubuntu@{EC2_INSTANCE_PUBLIC_NETWORK_ADDRESS}:/home/ubuntu/.tanzu dist
rm -Rf dist/.tanzu/tkg
```
> Replace `{SSH_PRIVATE_KEY_PATH_TO_FILE}` and `{EC2_INSTANCE_PUBLIC_NETWORK_ADDRESS}`

Put .kube, .kube-tkg and .tanzu directories from workstation to toolset jumpbox with Tanzu 1.4.0 CLI installed

```
scp -r -i {SSH_PRIVATE_KEY_PATH_TO_FILE} dist/.kube ubuntu@{EC2_INSTANCE_PUBLIC_NETWORK_ADDRESS}:/home/ubuntu
scp -r -i {SSH_PRIVATE_KEY_PATH_TO_FILE} dist/.kube-tkg ubuntu@{EC2_INSTANCE_PUBLIC_NETWORK_ADDRESS}:/home/ubuntu
scp -r -i {SSH_PRIVATE_KEY_PATH_TO_FILE} dist/.tanzu ubuntu@{EC2_INSTANCE_PUBLIC_NETWORK_ADDRESS}:/home/ubuntu
```
> Replace `{SSH_PRIVATE_KEY_PATH_TO_FILE}` and `{EC2_INSTANCE_PUBLIC_NETWORK_ADDRESS}`.  Note that second argument value here should be to a different instance.

To identify existing Tanzu Kubernetes Grid management clusters, run

```
kubectl --kubeconfig ~/.kube-tkg/config config get-contexts
```

For each management cluster listed in the output, restore it to the `~/.config/tanzu` directory and CLI by running

```
tanzu login --kubeconfig ~/.kube-tkg/config --context {NAME} --name {CLUSTER}
```
> Replace `{NAME}` and `{CLUSTER}` with values from each row matching column headers

Set management cluster listed in the output, run

```
kubectl config use-context {NAME}
```
> Replace `{NAME}` with a value listed under NAME column of prior step's output

To verify you have the Tanzu CLI aware of the management server(s)

```
tanzu config server list
```

You should see some output like the following

```
NAME          TYPE               ENDPOINT  PATH                           CONTEXT
zoolabs-mgmt  managementcluster            /home/ubuntu/.kube-tkg/config  zoolabs-mgmt-admin@zoolabs-mgmt
```

### Use Tanzu 1.4.0 CLI to upgrade management cluster

To execute an upgrade

```
export AWS_REGION={REGION}
tanzu management-cluster upgrade {MANAGEMENT_CLUSTER_NAME} --os-name ubuntu --os-version 20.04 --os-arch amd64
```
> Replace `{REGION}` with a valid AWS region, this should be the region where you had originally deployed the management cluster.  Replace `{MANAGEMENT_CLUSTER_NAME}` with name of the management cluster.  You will be asked for confirmation before proceeding with the upgrade.  Answer `y`.  Depending on the number of control plane and worker nodes comprising your management cluster, you may expect to wait 30 minutes or longer before the upgrade process completes.


### Use Tanzu 1.4.0 CLI to upgrade workload cluster

Show the version of Kubernetes that is running in the management cluster and all of the clusters that it manages

```
tanzu cluster list --include-management-cluster
```

Sample output

```
NAME              NAMESPACE   STATUS   CONTROLPLANE  WORKERS  KUBERNETES        ROLES       PLAN
zoolabs-workload  default     running  3/3           3/3      v1.20.5+vmware.1  <none>      prod
zoolabs-mgmt      tkg-system  running  3/3           1/1      v1.21.2+vmware.1  management  prod
```

Discover which versions of Kubernetes are made available by a management cluster

```
tanzu kubernetes-release get
```

Discover the TKR versions that are available for a specific workload cluster by specifying the cluster name

```
tanzu cluster available-upgrades get {WORKLOAD_CLUSTER_NAME}
```
> Replace `{WORKLOAD_CLUSTER_NAME}` with the name of an existing workload cluster under management by the management cluster.

Sample output

```
NAME                             VERSION                        COMPATIBLE
v1.20.5---vmware.2-fips.1-tkg.1  v1.20.5+vmware.2-fips.1-tkg.1  False
v1.20.5---vmware.2-tkg.1         v1.20.5+vmware.2-tkg.1         False
v1.20.8---vmware.1-tkg.2         v1.20.8+vmware.1-tkg.2         True
v1.21.2---vmware.1-tkg.1         v1.21.2+vmware.1-tkg.1         True
```

To execute an upgrade

```
tanzu cluster upgrade {WORKLOAD_CLUSTER_NAME}
```
> Replace `{REGION}` with a valid AWS region, this should be the region where you had originally deployed the management cluster.  Replace `{WORKLOAD_CLUSTER_NAME}` with name of the workload cluster.  You will be asked for confirmation before proceeding with the upgrade.  Answer `y`.  Depending on the number of control plane and worker nodes comprising your workload cluster, you may expect to wait 30 minutes or longer before the upgrade process completes.