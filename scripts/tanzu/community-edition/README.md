# Tanzu Community Edition Quickstart Guide

## Download and install CLI

```
cd /tmp
curl -LO https://github.com/vmware-tanzu/community-edition/releases/download/v0.9.1/tce-linux-amd64-v0.9.1.tar.gz
tar xvf tce-linux-amd64-v0.9.1.tar.gz
./tce-linux-amd64-v0.9.1/install.sh
```

## Install on Docker

> We're basically repeating steps as described [here](https://tanzucommunityedition.io/docs/latest/docker-install-mgmt/).

### Pre-pull HA proxy

```
docker pull kindest/haproxy:v20210715-a6da3463
```

### Create management cluster

```
tanzu management-cluster create -i docker --name tanzu-d-mgmt -v 10 --plan dev --ceip-participation=false
```
> You may want to replace the `--name` with your own cluster name.

### Validate management cluster got created

```
❯ tanzu management-cluster get
  NAME          NAMESPACE   STATUS   CONTROLPLANE  WORKERS  KUBERNETES        ROLES
  tanzu-d-mgmt  tkg-system  running  1/1           1/1      v1.21.2+vmware.1  management


Details:

NAME                                                             READY  SEVERITY  REASON  SINCE  MESSAGE
/tanzu-d-mgmt                                                    True                     19m
├─ClusterInfrastructure - DockerCluster/tanzu-d-mgmt             True                     19m
├─ControlPlane - KubeadmControlPlane/tanzu-d-mgmt-control-plane  True                     19m
│ └─Machine/tanzu-d-mgmt-control-plane-qxbts                     True                     19m
└─Worker
  └─MachineDeployment/tanzu-d-mgmt-md-0
    └─Machine/tanzu-d-mgmt-md-0-58d597794d-pvcf6                 True                     19m


Providers:

  NAMESPACE                          NAME                   TYPE                    PROVIDERNAME  VERSION  WATCHNAMESPACE
  capd-system                        infrastructure-docker  InfrastructureProvider  docker        v0.3.23
  capi-kubeadm-bootstrap-system      bootstrap-kubeadm      BootstrapProvider       kubeadm       v0.3.23
  capi-kubeadm-control-plane-system  control-plane-kubeadm  ControlPlaneProvider    kubeadm       v0.3.23
  capi-system                        cluster-api            CoreProvider            cluster-api   v0.3.23
```

### Obtain credentials to the management cluster

```
tanzu management-cluster kubeconfig get tanzu-d-mgmt --admin
```
> Replace `tanzu-d-mgmt` with your own cluster name.

### Target the management cluster

```
kubectl config use-context tanzu-d-mgmt-admin@tanzu-d-mgmt
```
> Your cluster context may be different.

```
❯ kubectl get nodes
NAME                                 STATUS   ROLES                  AGE   VERSION
tanzu-d-mgmt-control-plane-qxbts     Ready    control-plane,master   30m   v1.21.2+vmware.1-360497810732255795
tanzu-d-mgmt-md-0-58d597794d-pvcf6   Ready    <none>                 30m   v1.21.2+vmware.1-360497810732255795
```
> Your node names may be different.

### Create workload cluster

```
tanzu cluster create tanzu-d-workload --plan dev
```
> Replace `tanzu-d-workload` with your own cluster name.

### Validate the workload cluster got created

```
tanzu cluster list
```

### Scale the workload cluster

```
tanzu cluster scale tanzu-d-workload --worker-machine-count 5
```
> Replace `tanzu-d-workload` with your own cluster name.

### Obtain credentials to the workload cluster

```
tanzu cluster kubeconfig get tanzu-d-workload --admin
```
> Replace `tanzu-d-workload` with your own cluster name.

### Target the workload cluster

```
kubectl config use-context tanzu-d-workload-admin@tanzu-d-workload
```
> Your cluster context may be different.

```
❯ kubectl get nodes -o wide
NAME                                     STATUS   ROLES                  AGE     VERSION                               INTERNAL-IP   EXTERNAL-IP   OS-IMAGE           KERNEL-VERSION        CONTAINER-RUNTIME
tanzu-d-workload-control-plane-9fv9s     Ready    control-plane,master   9m4s    v1.21.2+vmware.1-360497810732255795   172.18.0.6    <none>        Ubuntu 20.04 LTS   5.13.0-7620-generic   containerd://1.3.3-14-g449e9269
tanzu-d-workload-md-0-678d98b488-88rn8   Ready    <none>                 4m4s    v1.21.2+vmware.1-360497810732255795   172.18.0.9    <none>        Ubuntu 20.04 LTS   5.13.0-7620-generic   containerd://1.3.3-14-g449e9269
tanzu-d-workload-md-0-678d98b488-9cltb   Ready    <none>                 4m4s    v1.21.2+vmware.1-360497810732255795   172.18.0.11   <none>        Ubuntu 20.04 LTS   5.13.0-7620-generic   containerd://1.3.3-14-g449e9269
tanzu-d-workload-md-0-678d98b488-9qjtz   Ready    <none>                 8m51s   v1.21.2+vmware.1-360497810732255795   172.18.0.7    <none>        Ubuntu 20.04 LTS   5.13.0-7620-generic   containerd://1.3.3-14-g449e9269
tanzu-d-workload-md-0-678d98b488-b55v4   Ready    <none>                 4m4s    v1.21.2+vmware.1-360497810732255795   172.18.0.10   <none>        Ubuntu 20.04 LTS   5.13.0-7620-generic   containerd://1.3.3-14-g449e9269
tanzu-d-workload-md-0-678d98b488-p62xd   Ready    <none>                 4m4s    v1.21.2+vmware.1-360497810732255795   172.18.0.8    <none>        Ubuntu 20.04 LTS   5.13.0-7620-generic   containerd://1.3.3-14-g449e9269
```
> Your node names may be different.

### Verify everything up-and-running via Docker CLI

```
❯ docker ps
CONTAINER ID   IMAGE                                                         COMMAND                  CREATED          STATUS          PORTS                                  NAMES
c3b4b3c4c63a   projects.registry.vmware.com/tkg/kind/node:v1.21.2_vmware.1   "/usr/local/bin/entr…"   7 minutes ago    Up 6 minutes                                           tanzu-d-workload-md-0-678d98b488-88rn8
b07b465a7865   projects.registry.vmware.com/tkg/kind/node:v1.21.2_vmware.1   "/usr/local/bin/entr…"   7 minutes ago    Up 6 minutes                                           tanzu-d-workload-md-0-678d98b488-9cltb
e90175da3515   projects.registry.vmware.com/tkg/kind/node:v1.21.2_vmware.1   "/usr/local/bin/entr…"   7 minutes ago    Up 6 minutes                                           tanzu-d-workload-md-0-678d98b488-b55v4
cc5eac41ad49   projects.registry.vmware.com/tkg/kind/node:v1.21.2_vmware.1   "/usr/local/bin/entr…"   7 minutes ago    Up 6 minutes                                           tanzu-d-workload-md-0-678d98b488-p62xd
f9b685c843d0   projects.registry.vmware.com/tkg/kind/node:v1.21.2_vmware.1   "/usr/local/bin/entr…"   11 minutes ago   Up 11 minutes                                          tanzu-d-workload-md-0-678d98b488-9qjtz
773ff059f897   projects.registry.vmware.com/tkg/kind/node:v1.21.2_vmware.1   "/usr/local/bin/entr…"   12 minutes ago   Up 12 minutes   44005/tcp, 127.0.0.1:44005->6443/tcp   tanzu-d-workload-control-plane-9fv9s
dd20dc844464   kindest/haproxy:v20210715-a6da3463                            "haproxy -sf 7 -W -d…"   12 minutes ago   Up 12 minutes   46649/tcp, 0.0.0.0:46649->6443/tcp     tanzu-d-workload-lb
04bca80a34d6   projects.registry.vmware.com/tkg/kind/node:v1.21.2_vmware.1   "/usr/local/bin/entr…"   50 minutes ago   Up 50 minutes                                          tanzu-d-mgmt-md-0-58d597794d-pvcf6
7463df06548c   projects.registry.vmware.com/tkg/kind/node:v1.21.2_vmware.1   "/usr/local/bin/entr…"   51 minutes ago   Up 51 minutes   33275/tcp, 127.0.0.1:33275->6443/tcp   tanzu-d-mgmt-control-plane-qxbts
0e777afb486f   kindest/haproxy:v20210715-a6da3463                            "haproxy -sf 7 -W -d…"   51 minutes ago   Up 51 minutes   40393/tcp, 0.0.0.0:40393->6443/tcp     tanzu-d-mgmt-lb
```
> Your mix of running containers may be different.

### Teardown

```
docker kill $(docker ps -a -q)
docker rm $(docker ps -a -q)
kubectl config delete-context tanzu-d-workload-admin@tanzu-d-workload
kubectl config delete-context tanzu-d-mgmt-admin@tanzu-d-mgmt
```