# Terraform a GKE Cluster

Based on the following Terraform [example](https://www.terraform.io/docs/providers/google/r/container_cluster.html) we'll create a public cluster.

Assumes a service account has been created with appropriate role and permissions to create a GKE cluster.

## Copy sample configuration

```
cp terraform.tfvars.sample terraform.tfvars
```

## Edit `terraform.tfvars`

Amend the values for

* `gcp_project`
* `gcp_service_account_credentials`
* `gcp_region`

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
./set-kubectl-context.sh {gke-cluster-name} {gke-zone}
```

## Resizing a cluster

See [Resizing a cluster](https://cloud.google.com/kubernetes-engine/docs/how-to/resizing-a-cluster).

## Validate you have some pods running

```
kubectl get pods -A
```

## Tear down the cluster

```
./destroy-cluster.sh
```
