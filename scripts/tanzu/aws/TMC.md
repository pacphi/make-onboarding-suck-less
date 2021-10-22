# Multi-cluster governance with Tanzu Mission Control

Start [here](https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/index.html).

Then acquaint yourself with the [concepts](https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/services/tanzumc-concepts/GUID-9E6DEA00-C368-4B06-B93E-BA1916EB2929.html).

## Put a workload cluster under management

We're going to attach a workload cluster to [Tanzu Mission Control](https://tanzu.vmware.com/mission-control).


### Authenticate

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


### Create a cluster group

Groups are used to coalesce and manage workload clusters

```
tmc clustergroup create --name {NAME} --description "{DESCRIPTION}"
```

> You may also [do this from the UI](https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/services/tanzumc-getstart/GUID-07782073-0803-4D93-9F27-D2F6EF2EBBAC.html)


### Attach a workload cluster


```
tmc cluster attach -g {GROUP} -n {NAME} -f {NAME}-tmc-attach-k8s-manifest.yml
kubectl apply -f  {NAME}-tmc-attach-k8s-manifest.yml
```

> Refer to [What Happens When You Attach a Cluster](https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/services/tanzumc-concepts/GUID-147472ED-16BB-4AAA-9C35-A951C5ADA88A.html)

> You may also [do this from the UI](https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/services/tanzumc-getstart/GUID-F0162E40-8D47-45D7-9EA1-83B64B380F5C.html)


## Implementing policy management across clusters

> Consult [Policy-driven cluster management](https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/services/tanzumc-concepts/GUID-847414C9-EF54-44E5-BA62-C4895160CE1D.html).

Peruse [this git repository](https://github.com/warroyo/tmc-cli-examples/tree/main/policy) for some examples to get started with.