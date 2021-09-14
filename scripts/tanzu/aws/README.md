# Tanzu Kubernetes Grid on AWS

## One-time Setup

On your workstation or laptop ensure you have Docker Desktop installed.

Use a pre-built [Docker container image](../../../docker/README.md) to create the Cloud Formation Stack.

```
docker run --rm -it tanzu/k8s-toolkit /bin/bash
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
  aws ec2 run-instances --image-id {AMI_ID} --instance-type=m5x.large --key-name {KEY_NAME} --iam-instance-profile Name=control-plane.tkg.cloud.vmware.com --security-group-ids {SECURITY_GROUP_ID}
  ```
  > Replace `{AMI_ID}` above with the AMI ID of the image you're hosting in your AWS account and region.  Use the same `{KEY_NAME}` you created earlier for the SSH key. And replace `{SECURITY_GROUP_ID}` with the id of a security group that has an inbound rule that allows for SSH access (preferably restricted to single IP address).


## Connect to EC2 toolset instance

* SSH into instance
  ```
  ssh -i $HOME/.ssh/{KEY_NAME} ubuntu@{EC2_INSTANCE_PUBLIC_IP_ADDRESS}.{AWS_REGION}.compute.amazonaws.com
  ```
  > Use the same `{KEY_NAME}` you created earlier for the SSH key.  Replace `{AWS_REGION}` and `{EC2_INSTANCE_PUBLIC_IP_ADDRESS}` with appropriate values.

* Install Tanzu CLI plugins
  ```
  tanzu plugin install --local cli all
  ```


## Deploy management and workload clusters

### Create Kind cluster

We'll create a reusable bootstrap cluster, first:

```
cat >bootstrap-config.yml <<EOF
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

Obtain a Tanzu Mission Control registration URL by following the steps in [Register a Management Cluster with Tanzu Mission Control](https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/services/tanzumc-using/GUID-EB507AAF-5F4F-400F-9623-BA611233E0BD.html).

### Create Management cluster

Consult the [sample config](aws-mgmt-cluster-config.sample.yaml) and add and/or update [property values](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.3/vmware-tanzu-kubernetes-grid-13/GUID-tanzu-config-reference.html) as per your specific [needs](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.3/vmware-tanzu-kubernetes-grid-13/GUID-mgmt-clusters-aws.html).  Create a file based on these contents using an editor of your choice (e.g., nano, vi).

```
kubectl config use-context kind-kind
tanzu management-cluster create --file aws-mgmt-cluster-config.sample.yaml --use-existing-bootstrap-cluster
```
> Feel free to copy, rename and/or replace the `--file` filename argument above.  If you followed the sample configuration it'll take ~20 minutes to provision the supporting infrastructure.

To address a defect that would eventually prevent you from life-cycle managing the management cluster, we will need to blank the capa-controller secret and patch the deployment to include some affinity and toleration rules.

Create the patch file.

```
cat >patch-mgmt-deployment-config.yml <<EOF
spec:
  template:
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: "node-role.kubernetes.io/control-plane"
                operator: "Exists"
            - matchExpressions:
              - key: "node-role.kubernetes.io/master"
                operator: "Exists"
      tolerations:
      - effect: "NoSchedule"
        key: "node-role.kubernetes.io/control-plane"
      - effect: "NoSchedule"
        key: "node-role.kubernetes.io/master"
EOF
```

Set the kubectl context.  (Note: this is a sample).

```
ubuntu@ip-172-31-25-21:~$ kubectl config get-contexts
CURRENT   NAME                              CLUSTER        AUTHINFO             NAMESPACE
*         kind-kind                         kind-kind      kind-kind
          zoolabs-mgmt-admin@zoolabs-mgmt   zoolabs-mgmt   zoolabs-mgmt-admin
ubuntu@ip-172-31-25-21:~$ kubectl config use-context zoolabs-mgmt-admin@zoolabs-mgmt
Switched to context "zoolabs-mgmt-admin@zoolabs-mgmt".
```

Now execute the commands

```
kubectl get secret capa-manager-bootstrap-credentials -n capa-system -o json | jq '.data["credentials"]="Cg=="' | kubectl apply -f -
kubectl patch deployment capa-controller-manager -n capa-system --patch-file patch-mgmt-deployment-config.yml
```

### Create Workload cluster

Consult the [sample config](aws-workload-cluster-config.sample.yaml) and add and/or update [property values](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.3/vmware-tanzu-kubernetes-grid-13/GUID-tanzu-config-reference.html) as per your specific needs.  Create a file based on these contents using an editor of your choice (e.g., nano, vi).

```
tanzu cluster create --file aws-workload-cluster-config.sample.yaml
```

### Teardown Workload cluster

```
tanzu cluster delete zoolabs-workload
```
> Feel free to copy, rename and/or replace the `--file` filename argument above.  If you followed the sample configuration it'll take ~10 minutes to provision the supporting infrastructure.

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