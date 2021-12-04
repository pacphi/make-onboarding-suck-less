# Terraform an EKS Cluster

Based on the following Terraform [example](https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.htm).

Assumes:

* IAM user has been created with appropriate role and permissions to create an EKS cluster

## Copy sample configuration

```
cp terraform.tfvars.sample terraform.tfvars
```

## Edit `terraform.tfvars`

Amend the values for

* `eks_name`
* `desired_nodes`
* `min_nodes`
* `max_nodes`
* `kubernetes_version`
* `region`
* `availability_zones`
* `ssh_key_name`
* `node_pool_instance_type`


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
./set-kubectl-context.sh {aws-region} {eks-cluster-name}
```

## Resizing a cluster

See [How can I check, scale, delete, or drain my worker nodes in Amazon EKS?](https://aws.amazon.com/premiumsupport/knowledge-center/eks-worker-node-actions/)

## Validate you have some pods running

```
kubectl get pods -A
```

## Teardown the cluster

```
./destroy-cluster.sh
```
