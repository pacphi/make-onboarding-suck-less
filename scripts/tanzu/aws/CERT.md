# Trust Custom CA Certificates on Tanzu Kubernetes Grid Cluster Nodes

Consult the [documentation](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-cluster-lifecycle-secrets.html#custom-ca).

If you want to create a certificate you have a few options.

For the purposes of this tutorial we're going to employ a locally trusted certificate that is created by [mkcert](https://github.com/FiloSottile/mkcert).


## Create the CA

Let's create a root certificate.

```
mkcert -install
openssl x509 -in "$(mkcert -CAROOT)"/rootCA.pem -inform PEM -out "$(mkcert -CAROOT)"/rootCA.crt
```

Place yourself in the ytt overlay directory for AWS infrastructure.

```
cd ~/.config/tanzu/tkg/providers/infrastructure-aws/ytt
```


## Create the overlay

Let's create a new overlay.

```
cat > ca-cert-overlay.yaml <<EOF
#@ load("@ytt:overlay", "overlay")
#@ load("@ytt:data", "data")

#! This ytt overlay adds additional custom CA certificates on TKG cluster nodes, so containerd and other tools trust these CA certificates.
#! It works when using Photon or Ubuntu as the TKG node template on all TKG infrastructure providers.

#! Trust your custom CA certificates on all Control Plane nodes.
#@overlay/match by=overlay.subset({"kind":"KubeadmControlPlane"})
---
spec:
  kubeadmConfigSpec:
    #@overlay/match missing_ok=True
    files:
      #@overlay/append
      - content: #@ data.read("tkg-custom-ca.pem")
        owner: root:root
        permissions: "0644"
        path: /etc/ssl/certs/tkg-custom-ca.pem
    #@overlay/match missing_ok=True
    preKubeadmCommands:
      #! For Photon OS
      #@overlay/append
      - '! which rehash_ca_certificates.sh 2>/dev/null || rehash_ca_certificates.sh'
      #! For Ubuntu
      #@overlay/append
      - '! which update-ca-certificates 2>/dev/null || (mv /etc/ssl/certs/tkg-custom-ca.pem /usr/local/share/ca-certificates/tkg-custom-ca.crt && update-ca-certificates)'

#! Trust your custom CA certificates on all worker nodes.
#@overlay/match by=overlay.subset({"kind":"KubeadmConfigTemplate"})
---
spec:
  template:
    spec:
      #@overlay/match missing_ok=True
      files:
        #@overlay/append
        - content: #@ data.read("tkg-custom-ca.pem")
          owner: root:root
          permissions: "0644"
          path: /etc/ssl/certs/tkg-custom-ca.pem
      #@overlay/match missing_ok=True
      preKubeadmCommands:
        #! For Photon OS
        #@overlay/append
        - '! which rehash_ca_certificates.sh 2>/dev/null || rehash_ca_certificates.sh'
        #! For Ubuntu
        #@overlay/append
        - '! which update-ca-certificates 2>/dev/null || (mv /etc/ssl/certs/tkg-custom-ca.pem /usr/local/share/ca-certificates/tkg-custom-ca.crt && update-ca-certificates)'
EOF
```

Add the Certificate Authority to a new tkg-custom-ca.pem file.

```
cp "$(mkcert -CAROOT)"/rootCA.pem tkg-custom-ca.pem
```

You're now ready to create a new workload cluster.  That cluster's and any subsequently created workload cluster's nodes will allow for images to be pulled from a container registry employing the same certificate.

### Adjustment for production cluster plans

Note: if you set `CLUSTER_PLAN: prod` in your cluster configuration, you will have to amend the overlay above.

Where you see occurrences of

```
#@overlay/match by=overlay.subset({"kind":"KubeadmControlPlane"})
```
or

```
#@overlay/match by=overlay.subset({"kind":"KubeadmConfigTemplate"})
```

replace with

```
#@overlay/match by=overlay.subset({"kind":"KubeadmControlPlane"}), expects="1+"
```
or

```
#@overlay/match by=overlay.subset({"kind":"KubeadmConfigTemplate"}), expects="1+"
```
respectively.


## Create a workload cluster

With the overlay in place, [create a workload cluster](README.md#create-workload-cluster).


## Verify that the CA was injected

Make sure your context is set to target the management cluster.

Note that the following API resources have been installed

```
ubuntu@ip-172-31-61-62:~$ kubectl api-resources | grep Kube
kubeadmconfigs                                 bootstrap.cluster.x-k8s.io/v1alpha3                  true         KubeadmConfig
kubeadmconfigtemplates                         bootstrap.cluster.x-k8s.io/v1alpha3                  true         KubeadmConfigTemplate
kubeadmcontrolplanes              kcp          controlplane.cluster.x-k8s.io/v1alpha3               true         KubeadmControlPlane
tanzukubernetesreleases           tkr          run.tanzu.vmware.com/v1alpha1                        false        TanzuKubernetesRelease
```

Let's list all the KubeadmControlPlane and KubeadmConfigTemplate resources

```
kubectl get KubeadmControlPlane,KubeadmConfigTemplate -A
```

For example

```
ubuntu@ip-172-31-61-62:~$ kubectl get KubeadmControlPlane,KubeadmConfigTemplate -A
NAMESPACE    NAME                                                                             INITIALIZED   API SERVER AVAILABLE   VERSION            REPLICAS   READY   UPDATED   UNAVAILABLE
default      kubeadmcontrolplane.controlplane.cluster.x-k8s.io/zoolabs-harbor-control-plane   true          true                   v1.21.2+vmware.1   3          3       3
default      kubeadmcontrolplane.controlplane.cluster.x-k8s.io/zoolabs-tbs-control-plane      true          true                   v1.21.2+vmware.1   3          3       3
tkg-system   kubeadmcontrolplane.controlplane.cluster.x-k8s.io/zoolabs-mgmt-control-plane     true          true                   v1.21.2+vmware.1   3          3       3

NAMESPACE    NAME                                                                   AGE
default      kubeadmconfigtemplate.bootstrap.cluster.x-k8s.io/zoolabs-harbor-md-0   5d2h
default      kubeadmconfigtemplate.bootstrap.cluster.x-k8s.io/zoolabs-harbor-md-1   5d2h
default      kubeadmconfigtemplate.bootstrap.cluster.x-k8s.io/zoolabs-harbor-md-2   5d2h
default      kubeadmconfigtemplate.bootstrap.cluster.x-k8s.io/zoolabs-tbs-md-0      11h
default      kubeadmconfigtemplate.bootstrap.cluster.x-k8s.io/zoolabs-tbs-md-1      11h
default      kubeadmconfigtemplate.bootstrap.cluster.x-k8s.io/zoolabs-tbs-md-2      11h
tkg-system   kubeadmconfigtemplate.bootstrap.cluster.x-k8s.io/zoolabs-mgmt-md-0     7d1h
tkg-system   kubeadmconfigtemplate.bootstrap.cluster.x-k8s.io/zoolabs-mgmt-md-1     7d1h
tkg-system   kubeadmconfigtemplate.bootstrap.cluster.x-k8s.io/zoolabs-mgmt-md-2     7d1h
```

We want to verify that the CA was injected into both the _control plane_ and _worker_ nodes.

### Inspect control plane node

```
kubectl get kcp {node_name} -o yaml | grep -i tkg-custom-ca.pem
```

For example

```
kubectl get kcp zoolabs-tbs-control-plane -o yaml | grep -i tkg-custom-ca.pem
```

### Inspect worker node

```
kubectl get KubeadmConfigTemplate {template_name} -o yaml | grep -i tkg-custom-ca.pem
```

For example

```
kubectl get KubeadmConfigTemplate zoolabs-tbs-md-0 -o yaml | grep -i tkg-custom-ca.pem
```

