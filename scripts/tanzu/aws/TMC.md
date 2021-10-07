# Put workload cluster under management

We're going to attach a workload cluster to [Tanzu Mission Control](https://tanzu.vmware.com/mission-control).


## Authenticate

Here's a sample interaction

```
ubuntu@ip-172-31-25-21:~$ tmc login
i If you don't have an API token, visit the VMware Cloud Services console, select your organization, and create an API token with the TMC service roles:
  https://console.cloud.vmware.com/csp/gateway/portal/#/user/tokens
? API Token ****************************************************************
? Login context name pacphi
? Select default log level info
? Management Cluster Name zoolabs-mgmt
? Provisioner Name pacphi
```


## Create a cluster group

Groups are used to coalesce and manage workload clusters

```
tmc clustergroup create --name {NAME} --description "{DESCRIPTION}"
```


## Attach a workload cluster

```
tmc cluster attach --cluster-group {GROUP} --name {NAME} --file {NAME}-tmc-attach-k8s-manifest.yml
kubectl apply -f  {NAME}-tmc-attach-k8s-manifest.yml
```