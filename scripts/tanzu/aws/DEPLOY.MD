# Deploy an application to Tanzu Kubernetes Grid on AWS

Where are you performing your development work?

Make sure you've installed the pre-requisite tooling.


## Restore the ~/.config/tanzu directory

If...

* You'd been working on a jumpbox in an AWS region and already deployed a management cluster and workload clusters hosting Harbor and TBS
* Management cluster hasn't been registered with TMC
* Workload clusters haven't been registered with or attached to TMC
* You've decided to shift to working from your laptop or workstation

... proceed with the following steps to reconstitute config from jumpbox and subsequently obtain cluster credentials

Fetch .kube, .kube-tkg, and .tanzu directories from toolset jumpbox with Tanzu 1.4.0 CLI installed to workstation

```
scp -r -i {SSH_PRIVATE_KEY_PATH_TO_FILE} ubuntu@{EC2_INSTANCE_PUBLIC_NETWORK_ADDRESS}:/home/ubuntu/.kube dist
scp -r -i {SSH_PRIVATE_KEY_PATH_TO_FILE} ubuntu@{EC2_INSTANCE_PUBLIC_NETWORK_ADDRESS}:/home/ubuntu/.kube-tkg dist
scp -r -i {SSH_PRIVATE_KEY_PATH_TO_FILE} ubuntu@{EC2_INSTANCE_PUBLIC_NETWORK_ADDRESS}:/home/ubuntu/.tanzu dist
rm -Rf dist/.tanzu/tkg
```
> Replace `{SSH_PRIVATE_KEY_PATH_TO_FILE}` and `{EC2_INSTANCE_PUBLIC_NETWORK_ADDRESS}`

To identify existing Tanzu Kubernetes Grid management clusters, run

```
kubectl --kubeconfig ~/.kube-tkg/config config get-contexts
```

For each management cluster listed in the output, restore it to the `~/.config/tanzu` directory and CLI by running

```
tanzu login --kubeconfig ~/.kube-tkg/config --context {NAME} --name {CLUSTER}
```
> Replace `{NAME}` and `{CLUSTER}` with values from each row matching column headers

## Fetch credentials for TBS cluster

```
tanzu cluster kubeconfig get {TBS_WORKLOAD_CLUSTER_NAME} --admin
```

## Target TBS cluster

```
kubectl config get-contexts
kubectl config use-context {TBS_WORKLOAD_CLUSTER_NAME}-admin@{TBS_WORKLOAD_CLUSTER_NAME}
```

## Obtain container registry secrets

```
kubectl get secret registry-credentials -o yaml > registry-credentials.yml
```

## Fetch credentials for development cluster

```
tanzu cluster kubeconfig get {DEV_WORKLOAD_CLUSTER_NAME} --admin
```

## Target development cluster

```
kubectl config get-contexts
kubectl config use-context {DEV_WORKLOAD_CLUSTER_NAME}-admin@{DEV_WORKLOAD_CLUSTER_NAME}
```

## Install cert-manager

```
tanzu package install cert-manager --package-name cert-manager.tanzu.vmware.com --version 1.1.0+vmware.1-tkg.2 --namespace cert-manager --create-namespace
```

Skip this step if cert-manager is already installed in the workload cluster

## Install Contour

```
cat > contour-data-values.yaml <<EOF
---
infrastructure_provider: aws
namespace: tanzu-system-ingress
contour:
 configFileContents: {}
 useProxyProtocol: false
 replicas: 2
 pspNames: "vmware-system-restricted"
 logLevel: info
envoy:
 service:
   type: LoadBalancer
   annotations: {}
   nodePorts:
     http: null
     https: null
   externalTrafficPolicy: Cluster
   aws:
     LBType: classic
   disableWait: false
 hostPorts:
   enable: true
   http: 80
   https: 443
 hostNetwork: false
 terminationGracePeriodSeconds: 300
 logLevel: info
 pspNames: null
certificates:
 duration: 8760h
 renewBefore: 360h
EOF

tanzu package install contour --package-name contour.tanzu.vmware.com --version 1.17.1+vmware.1-tkg.1 --namespace contour --values-file contour-data-values.yaml --create-namespace
```

Skip this step if contour is already installed in the workload cluster


## Create a namespace

```
kubectl create ns apps
```

## Create a secret

```
kubectl apply -f registry-credentials.yml --namespace apps
```

## Deploy an app

The deployment will consume the secret which has the credentials required to pull image from a private container registry.

Example manifest

```
cat > primes-dev-deployment.yml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: primes-dev
  name: primes-dev
spec:
  replicas: 3
  selector:
    matchLabels:
      app: primes-dev
  template:
    metadata:
      labels:
        app: primes-dev
    spec:
      imagePullSecrets:
      - name: registry-credentials
      containers:
      - image: harbor.lab.zoolabs.me/apps/primes@sha256:c9a561afcef1dd3ab33afc7710d9a9b028f9363034241b1f93131e5d2fdf1c66
        name: primes-dev
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: primes-dev
spec:
  ports:
  - port: 8080
    targetPort: 8080
  selector:
    app: "primes-dev"
EOF
```

Deploy it!

```
kubectl apply -f primes-dev-deployment.yml --namespace apps
```

## Connect to the app

We're going to use [kwt](https://github.com/vmware-tanzu/carvel-kwt).

```
sudo -E kwt net start
```

Let's calculate some primes!

Open another terminal session, then execute

```
curl http://primes-dev.apps.svc.cluster.local:8080/primes/1/20 | jq
```

To teardown the connection

```
sudo -E kwt net clean-up
```
