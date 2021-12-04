# Terraform an AKS Cluster

Based on the following Terraform [example](https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.htm).

Assumes:

* resource group already exists
* service account has been created with appropriate role and permissions to create an AKS cluster
* an SSH private/public [key-pair](https://www.ssh.com/ssh/keygen/) using RSA algorithm has been created

## Copy sample configuration

```
cp terraform.tfvars.sample terraform.tfvars
```

## Edit `terraform.tfvars`

Amend the values for

* `aks_resource_group`
* `enable_logs`
* `ssh_public_key`
* `az_subscription_id`
* `az_client_id`
* `az_client_secret`
* `az_tenant_id`
* `aks_region`
* `aks_name`
* `aks_nodes`
* `aks_node_type`
* `aks_pool_name`
* `aks_node_disk_size`

> You're also free to update any other input variable value

## Create the cluster

```
./create-cluster.sh
```

## List available clusters

```
./list-clusters.sh
```

## Update kubeconfig

Use the name and location of the cluster you just created to update `kubeconfig` and set the current context for `kubectl`

```
./set-kubectl-context.sh {aks-cluster-name} {azure-resource-group}
```

## Resizing a cluster

See [Scale cluster nodes](https://docs.microsoft.com/en-us/azure/////////aks/scale-cluster#scale-the-cluster-nodes)

## Validate you have some pods running

```
kubectl get pods -A
```

## Teardown the cluster

```
./destroy-cluster.sh
```
