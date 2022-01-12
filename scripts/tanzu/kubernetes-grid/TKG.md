# Tanzu Kubernetes Grid on AWS

## One-time Setup

On your workstation or laptop ensure you have Docker Desktop installed.

Use a pre-built [Docker container image](../../../docker/README.md) to create the Cloud Formation Stack.

```
docker run -it tanzu/k8s-toolkit /bin/bash
export AWS_REGION=us-west-2
export AWS_PAGER=
export AWS_ACCESS_KEY_ID=xxx
export AWS_SECRET_ACCESS_KEY=xxx
export AWS_SESSION_TOKEN=xxx
tanzu management-cluster permissions aws set
```
> Replace the values of `AWS_REGION`, `AWS_SECRET_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_SESSION_TOKEN` with your own settings and credentials.



After the stack is created we'll need to update the `control-plane.tkg.cloud.vmware.com` managed policy to add two more permissions.

Log into the AWS Console, visit IAM > Access Management > Policies and add these to the Action block of that policy:

```
"ec2:DescribeInstanceTypes",
"ec2:DescribeInstanceTypeOfferings",
```

[Launch an EC2 instance](../../../packer/aws/ubuntu/20_04/TEST.md) based on a public AMI ID that has the toolset pre-installed.

Here's the shortest path to take:

* Create key-pair
  ```
  ssh-keygen -t rsa -C "{KEY_NAME}" -f $HOME/.ssh/{KEY_NAME}
  aws ec2 import-key-pair --key-name "{KEY_NAME}" --public-key-material fileb://$HOME/.ssh/{KEY_NAME}.pub
  ```
  > Replace `{KEY_NAME}` above with the name of your public-private key-pair

* Create security group
  ```
  aws ec2 create-security-group \
    --description "Allow SSH access" \
    --group-name "ssh-access-security-group" \
    --vpc-id {VPC_ID}
  ```
  > Replace `{VPC_ID}` with id of an existing VPC in region you desire.  Note the security group id returned.

* Authorize ingress
  ```
  aws ec2 authorize-security-group-ingress \
    --group-id {SECURITY_GROUP_ID} \
    --protocol tcp \
    --port 22 \
    --cidr {IP_ADDRESS}
  ```
  > Replace `{SECURITY_GROUP_ID}` with security group id from prior step.  Replace `{IP_ADDRESS}` with IP address of host that has public Internet egress in order to estable an SSH terminal session.  Only this host will have access to EC2 instances with this security group bound.

* Create EC2 instance
  ```
  aws ec2 run-instances --image-id {AMI_ID} --instance-type=m5.xlarge --key-name {KEY_NAME} --iam-instance-profile Name=control-plane.tkg.cloud.vmware.com --security-group-ids {SECURITY_GROUP_ID}
  ```
  > Replace `{AMI_ID}` above with the AMI ID of the image you're hosting in your AWS account and region.  Use the same `{KEY_NAME}` you created earlier for the SSH key. And replace `{SECURITY_GROUP_ID}` with the id of a security group that has an inbound rule that allows for SSH access (preferably restricted to single IP address).

If you exited your Docker container without first copying the private/public keys, then you can:

```
docker ps -a
```
> Look for the container image id of the stopped container.


Restart the container with

```
docker container restart {IMAGE_ID}
```
> Replace `{IMAGE_ID}` with container image id of the restarted container image process.

Execute commands

```
docker container exec {IMAGE_ID} ls -la /home/docker/.ssh
```
> Replace `{IMAGE_ID}` with container image id of the restarted container image process.

You could emit or copy the contents with

```
docker container exec {IMAGE_ID} cat /home/docker/.ssh/{KEY_NAME} > $HOME/.ssh/{KEY_NAME}
docker container exec {IMAGE_ID} cat /home/docker/.ssh/{KEY_NAME}.pub > $HOME/.ssh/{KEY_NAME}.pub
chmod 400 $HOME/.ssh/{KEY_NAME}
```
> Replace `{IMAGE_ID}` and `{KEY_NAME}` as appropriate.


## Connect to EC2 toolset instance

Exit the Docker container before executing the following step.

* SSH into instance
  ```
  ssh -i $HOME/.ssh/{KEY_NAME} ubuntu@{EC2_INSTANCE_PUBLIC_IP_ADDRESS}.{AWS_REGION}.compute.amazonaws.com
  ```
  > Use the same `{KEY_NAME}` you created earlier for the SSH key.  Replace `{AWS_REGION}` and `{EC2_INSTANCE_PUBLIC_IP_ADDRESS}` with appropriate values.

At this point you should be connected to your EC2 instance.  Let's install some plugins that the `tanzu` CLI will use.

* Install Tanzu CLI plugins
  ```
  tanzu plugin install --local cli all
  ```


## Deploy management and workload clusters

### Create Kind cluster

We'll create a reusable bootstrap cluster, first:

```
cat > bootstrap-config.yml <<EOF
# a cluster with 3 control-plane nodes and 3 workers
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: control-plane
- role: control-plane
- role: worker
- role: worker
- role: worker
EOF
kind create cluster --config bootstrap-config.yml
```

### Create Management cluster

Consult the [sample config](aws/aws-mgmt-cluster-config.sample.yaml) and add and/or update [property values](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.3/vmware-tanzu-kubernetes-grid-13/GUID-tanzu-config-reference.html) as per your specific [needs](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.3/vmware-tanzu-kubernetes-grid-13/GUID-mgmt-clusters-aws.html).  Create a file based on these contents using an editor of your choice (e.g., nano, vi).

```
kubectl config use-context kind-kind
tanzu management-cluster create --file aws-mgmt-cluster-config.sample.yaml --use-existing-bootstrap-cluster
```
> Feel free to copy, rename and/or replace the `--file` filename argument above.  If you followed the sample configuration it'll take ~20 minutes to provision the supporting infrastructure.


Get credentials and set context

```
tanzu management-cluster kubeconfig get zoolabs-manager --admin
kubectl config use-context zoolabs-manager-admin@zoolabs-manager
```

### Create Workload cluster

Consult the [sample config](aws/aws-workload-cluster-config.sample.yaml) and add and/or update [property values](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.3/vmware-tanzu-kubernetes-grid-13/GUID-tanzu-config-reference.html) as per your specific needs.  Create a file based on these contents using an editor of your choice (e.g., nano, vi).

```
tanzu cluster create --file aws-workload-cluster-config.sample.yaml
```
> Feel free to copy, rename and/or replace the `--file` filename argument above.  If you followed the sample configuration it'll take ~20 minutes to provision the supporting infrastructure.


On completion, list the available workload clusters.

```
tanzu cluster list
```

```
NAME                    NAMESPACE  STATUS   CONTROLPLANE  WORKERS  KUBERNETES        ROLES   PLAN
zoolabs-workload        default    running  3/3           3/3      v1.21.2+vmware.1  <none>  prod
```

Obtain the new workload cluster kubectl configuration.

```
tanzu cluster kubeconfig get zoolabs-workload --admin
```

```
Credentials of cluster 'zoolabs-workload' have been saved
You can now access the cluster by running 'kubectl config use-context zoolabs-workload-admin@zoolabs-workload'
```

Set the context

```
kubectl config use-context zoolabs-workload-admin@zoolabs-workload
```

```
Switched to context "zoolabs-workload-admin@zoolabs-workload".
```

Then validate status

```
kubectl get nodes,pods -A
```

```
NAME                                            STATUS   ROLES                  AGE   VERSION
node/ip-10-0-0-227.us-west-2.compute.internal   Ready    <none>                 28m   v1.20.5+vmware.1
node/ip-10-0-0-76.us-west-2.compute.internal    Ready    control-plane,master   29m   v1.20.5+vmware.1
node/ip-10-0-2-207.us-west-2.compute.internal   Ready    control-plane,master   24m   v1.20.5+vmware.1
node/ip-10-0-2-228.us-west-2.compute.internal   Ready    <none>                 28m   v1.20.5+vmware.1
node/ip-10-0-4-206.us-west-2.compute.internal   Ready    <none>                 28m   v1.20.5+vmware.1
node/ip-10-0-4-215.us-west-2.compute.internal   Ready    control-plane,master   27m   v1.20.5+vmware.1

NAMESPACE     NAME                                                                   READY   STATUS    RESTARTS   AGE
kube-system   pod/antrea-agent-4l6sp                                                 2/2     Running   0          27m
kube-system   pod/antrea-agent-58slz                                                 2/2     Running   0          28m
kube-system   pod/antrea-agent-dzrk8                                                 2/2     Running   0          28m
kube-system   pod/antrea-agent-k8h2k                                                 2/2     Running   0          28m
kube-system   pod/antrea-agent-n6f48                                                 2/2     Running   0          28m
kube-system   pod/antrea-agent-ndgf6                                                 2/2     Running   0          24m
kube-system   pod/antrea-controller-7fd86b64bd-ztwm4                                 1/1     Running   0          28m
kube-system   pod/coredns-68d49685bd-2zmf9                                           1/1     Running   0          29m
kube-system   pod/coredns-68d49685bd-qzh92                                           1/1     Running   0          29m
kube-system   pod/etcd-ip-10-0-0-76.us-west-2.compute.internal                       1/1     Running   0          29m
kube-system   pod/etcd-ip-10-0-2-207.us-west-2.compute.internal                      1/1     Running   0          24m
kube-system   pod/etcd-ip-10-0-4-215.us-west-2.compute.internal                      1/1     Running   0          26m
kube-system   pod/kube-apiserver-ip-10-0-0-76.us-west-2.compute.internal             1/1     Running   0          29m
kube-system   pod/kube-apiserver-ip-10-0-2-207.us-west-2.compute.internal            1/1     Running   0          24m
kube-system   pod/kube-apiserver-ip-10-0-4-215.us-west-2.compute.internal            1/1     Running   0          26m
kube-system   pod/kube-controller-manager-ip-10-0-0-76.us-west-2.compute.internal    1/1     Running   1          29m
kube-system   pod/kube-controller-manager-ip-10-0-2-207.us-west-2.compute.internal   1/1     Running   0          24m
kube-system   pod/kube-controller-manager-ip-10-0-4-215.us-west-2.compute.internal   1/1     Running   0          26m
kube-system   pod/kube-proxy-dkgw8                                                   1/1     Running   0          29m
kube-system   pod/kube-proxy-drmzv                                                   1/1     Running   0          27m
kube-system   pod/kube-proxy-fc24q                                                   1/1     Running   0          28m
kube-system   pod/kube-proxy-gmknt                                                   1/1     Running   0          28m
kube-system   pod/kube-proxy-rj4j7                                                   1/1     Running   0          24m
kube-system   pod/kube-proxy-rrzcx                                                   1/1     Running   0          28m
kube-system   pod/kube-scheduler-ip-10-0-0-76.us-west-2.compute.internal             1/1     Running   1          29m
kube-system   pod/kube-scheduler-ip-10-0-2-207.us-west-2.compute.internal            1/1     Running   0          24m
kube-system   pod/kube-scheduler-ip-10-0-4-215.us-west-2.compute.internal            1/1     Running   0          26m
kube-system   pod/metrics-server-68b875f65b-jzknl                                    1/1     Running   0          28m
tkg-system    pod/kapp-controller-76f8756b46-d876z                                   1/1     Running   1          29m
```

### Teardown Workload cluster

```
tanzu cluster delete zoolabs-workload
```


### Teardown Management cluster

```
kubectl config use-context kind-kind
export AWS_REGION=us-west-2
tanzu management-cluster delete --use-existing-cleanup-cluster
```
> Replace the value of `AWS_REGION` if you deployed the management cluster in alternate region.

### Teardown Kind cluster

```
kind delete clusters kind
```


## Using K9s

If you see

```
 ____  __.________
|    |/ _/   __   \______
|      < \____    /  ___/
|    |  \   /    /\___ \
|____|__ \ /____//____  >
        \/            \/

Boom!! Unable to locate K8s cluster configuration.
```

then

```
mkdir -p $HOME/.k9s
```

and

```
k9s --kubeconfig $HOME/.kube/config
```


## Troubleshooting

If you see something like the following output on either _management_ or _workload_ cluster creation:

```
Validating configuration...
Warning: Pinniped configuration not found. Skipping pinniped configuration in workload cluster. Please refer to the documentation to check if you can configure pinniped on workload cluster manually
unable to verify if the AWS CloudFormation stack tkg-cloud-vmware-com is available in the AWS account.
Creating workload cluster 'zoolabs-workload-2'...
Waiting for cluster to be initialized...
Error: unable to wait for cluster and get the cluster kubeconfig: error waiting for cluster to be provisioned (this may take a few minutes): cluster creation failed, reason:'VpcReconciliationFailed', message:'0 of 7 completed'
```

then consult this Knowledge Base [article](https://kb.vmware.com/s/article/83313) for the fix.

```
Validating configuration...
Warning: Pinniped configuration not found. Skipping pinniped configuration in workload cluster. Please refer to the documentation to check if you can configure pinniped on workload cluster manually
unable to verify if the AWS CloudFormation stack tkg-cloud-vmware-com is available in the AWS account.
Creating workload cluster 'zoolabs-workload-2'...
Waiting for cluster to be initialized...
Error: unable to wait for cluster and get the cluster kubeconfig: error waiting for cluster to be provisioned (this may take a few minutes): cluster creation failed, reason:'NatGatewaysReconciliationFailed', message:'3 of 7 completed'
```

then consult this Knowledge Base [article](https://kb.vmware.com/s/article/85203) for the fix.