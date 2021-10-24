# Customizing Clusters and Plans with ytt Overlays

We're going to review a couple of specific use-cases leveraging [ytt Overlays](https://carvel.dev/ytt/docs/latest/ytt-overlays/) to customize Tanzu Kubernetes (workload) clusters.

> For more background on what is possible, have a look [here](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-ytt.html).


## Use Cases

### Internal load-balancer and custom subnet(s)

Consult this [gist](https://gist.github.com/warroyo/70d65466f5b1e10ec0a00de3f6528c0d).

Obtain the files:

```
cd /tmp
curl -LO https://gist.githubusercontent.com/warroyo/70d65466f5b1e10ec0a00de3f6528c0d/raw/82c718816eed2243512ad332df7dbe6f4fe86dac/cluster_config.yml
curl -LO https://gist.githubusercontent.com/warroyo/70d65466f5b1e10ec0a00de3f6528c0d/raw/82c718816eed2243512ad332df7dbe6f4fe86dac/custom_lb.yml
curl -LO https://gist.githubusercontent.com/warroyo/70d65466f5b1e10ec0a00de3f6528c0d/raw/82c718816eed2243512ad332df7dbe6f4fe86dac/custom_lb_values.yml
```

Open and review the contents of `cluster_config.yml`.  These additional property values affect how and where the cluster load-balancer will be created.  Append these to your workload cluster config.

Create a new folder for user customization.

```
mkdir -p $HOME/.tanzu/tkg/providers/ytt/04_user_customizations
```

Copy files into place:

```
cp /tmp/custom_lb.yml $HOME/.tanzu/tkg/providers/ytt/04_user_customizations
cp /tmp/custom_lb_values.yml $HOME/.tanzu/tkg/providers/ytt/04_user_customizations
```

Now all clusters [built](TKG.md#create-workload-cluster) that have the two property values included in the workload cluster config will trigger the use of the above overlay.


### High-availability cluster in one availability zone

> We're creating a new custom cluster plan.

Consult this [gist](https://gist.github.com/warroyo/827db5a3edfe36ffb13a5c8440f7ace0).

Obtain the files:

```
cd /tmp
curl -LO https://gist.githubusercontent.com/warroyo/827db5a3edfe36ffb13a5c8440f7ace0/raw/840264cab916f4b3f31ee514c085798b2bfb4eca/cluster-template-definition-ha1az.yaml
curl -LO https://gist.githubusercontent.com/warroyo/827db5a3edfe36ffb13a5c8440f7ace0/raw/840264cab916f4b3f31ee514c085798b2bfb4eca/ha1az.yml
```

Create a new folder for user customization (if you haven't done so already).

```
mkdir -p $HOME/.tanzu/tkg/providers/ytt/04_user_customizations
```

Copy files into place:

```
cp /tmp/cluster-template-definition-ha1az.yaml $/HOME/.tanzu/tkg/providers/infrastructure-aws/v0.6.4
cp /tmp/ha1az.yml $HOME/.tanzu/tkg/providers/ytt/04_user_customizations
```

Now you can specify the `ha1az` plan instead of `dev` or `prod` and it will create an HA cluster in one availability zone.
