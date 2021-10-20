# Implementing Continuous Application Deployment

We'll start with the assumption [you have already published an image](TBS.md#save-a-container-image) that you want to deploy.

Now we're going to walk thru the process of how to setup continuous deployment.

We're going to leverage the App spec of [kapp-controller](https://carvel.dev/kapp-controller/docs/latest/app-spec/) to do it!

First we need to target a workload cluster.

## Create namespace

```
kubectl create ns {namespace}
```
> Replace `{namespace}` with a name that would normally correspond to an environment; in this tutorial it will be `apps`.


## Create service account tied to namespace

Creates a namespace tied service account which has permissions to change any resource within that namespace. It will be used by App CR below.

```
cat > {namespace}-sa.yml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {namespace}-ns-sa
  namespace: {namespace}
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: {namespace}-ns-role
  namespace: {namespace}
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: {namespace}-ns-role-binding
  namespace: {namespace}
subjects:
- kind: ServiceAccount
  name: {namespace}-ns-sa
  namespace: {namespace}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: {namespace}-ns-role
EOF
```
> Replace occurrences of `{namespace}` with same name you defined in the earlier step.


```
kubectl apply -f {namespace}-sa.yml
```
> Replace `{namespace}` with same name you defined in the earlier step.


## Create the App CR

We're going to create a custom resource that corresponds to the application we want to deploy.

For both options below it's assumed you'll be pulling images from a private container registry, so you're going to need to deploy a secret that has the credentials.

Here's how you would:

* [obtain](DEPLOY.MD#obtain-container-registry-secrets)
  * Assumes you have access to the cluster where TBS is deployed.
* [deploy](DEPLOY.MD#create-a-secret)
  * Make sure you're targeting the right workload cluster

the secret.


### Option 1

Apply this CR when you want to gate changes

```
cat > primes-dev-cd-via-gitrepo.yml <<EOF
apiVersion: kappctrl.k14s.io/v1alpha1
kind: App
metadata:
  name: primes-dev
  namespace: {namespace}
spec:
  serviceAccountName: {namespace}-ns-sa
  fetch:
  - git:
      url: https://github.com/pacphi/k8s-manifests
      ref: origin/main
      subPath: com/fns/primes/{namespace}
  template:
  - ytt: {}
  deploy:
  - kapp: {}
EOF
```
> Replace occurrences of `{namespace}` with same name you defined in the earlier step.  This repo holds all the Kubernetes manifests for the app you'll continuously deploy.

You will have to orchestrate git commit updates by updating the SHA of the container image reference in `config.yml` file located under the `subPath` directory of the repo after each image tag and push (or `kp save image`) to a container registry.


If you do choose this for your CR, then you'll want to fork the `k8s-manifests` git repo for your own purposes.  And you'll want to fork the `primes` repo as defined in `config.yml`.  Note that the container `image` reference will need to be updated in `config.yml` because it's expected you will publish image updates to your own private container registry.


### Option 2

Apply this CR when you want to pull and deploy the latest image available updates from the container registry with no intermediary step

```
cat > primes-dev-cd-via-imagepull.yml <<EOF
kind: App
apiVersion: kappctrl.k14s.io/v1alpha1
metadata:
  name: primes-dev
  namespace: {namespace}
spec:
  serviceAccountName: {namespace}-ns-sa
  fetch:
  - image
      url: {registry-domain}/apps/primes:latest
      secretRef:
        name: registry-credentials
  template:
  - ytt: {}
  deploy:
  - kapp: {}
EOF
```
> Replace occurrences of `{namespace}` with same name you defined in the earlier step.  Replace `{registry-domain}` with a domain name (e.g., harbor.lab.zoolabs.me).

The drawback to choosing this option is that while it directly sources the latest image updates from a container registry it does not give you the option to configure environment variables.


## Deploy the App CR

Choose to deploy one of the App CR manifests you created in the previous step.

```
kapp deploy -a primes-dev -f primes-dev-cd-via-gitrepo.yml -y
```

or

```
kapp deploy -a primes-dev -f primes-dev-cd-via-imagepull.yml -y
```

Then

* check the output from `kubectl get app -n {namespace}` being careful to replace `{namespace}` with same name you defined in the earlier steps to see that app is deployed
* check the status of the App CR with `kapp inspect -a primes-dev --status`


## Simulate CI

Make sure you're targeting the cluster where TBS is installed.

To follow along here you must have chosen to author an App CR implementing a git repo reference.

Build the app and publish an updated image to the container registry.

In the real world we'd have a CI engine executing these steps.

(You'll want to work with a fork of the git repo mentioned below).

```
git clone https://github.com/fastnsilver/primes
cd primes
git checkout solution
sed -i 's/2.5.4/2.5.5/g' build.gradle
git add .
git commit -m "Update Spring Boot to 2.5.5"
git push

kp image save primes-dev \
  --git https://github.com/fastnsilver/primes \
  --git-revision $(git rev-parse --verify HEAD) \
  --tag {registry-domain}/apps/primes \
  --registry-ca-cert-path /home/ubuntu/.local/share/mkcert/rootCA.crt \
  --wait
```
> Replace `{registry-domain}` with a domain name (e.g., harbor.lab.zoolabs.me).


Obtain image SHA

```
kp image list
```
> Lists all images built.  You would need to scan and find the latest image corresponding to `primes-dev`.

or, if you're looking for a one-liner

```
kp image status primes-dev | sed -n '3 p' | cut -d ':' -f 2- | tr -d ' '
```

Use SHA to update the reference in your `k8s-manifests` git repo.  You're going to use your fork, OK?

Clone the manifests repo and use VIM to update the App CR
```
git clone https://github.com/pacphi/k8s-manifests
cd k8s-manifests
vi com/fns/primes/{namespace}/config.yml
```

Update the section that looks something like:

```
containers:
- name: primes-dev
  image: harbor.lab.zoolabs.me/apps/primes@sha256:061ac41e98cff9c90f9e6bd8d34b5666c3f2f91fe4bb6196d1855d702e49cdaf
```
> Replace the SHA.  You'll want to update the container registry domain too.

Then type

```
:wq
```

to save your update and exit VIM.


Now let's commit and push our update to `config.yml`.

```
git add .
git commit -m "Update primes to be powered by Spring Boot 2.5.5"
git push
```

Et voila!

Don't trust me?!

Confirm the image update was deployed.

Target cluster, then

```
kubectl get pods -n {namespace}
kubectl get pod primes-dev-{suffix} -n apps -o json | jq ".spec.containers[].image"
```
> Replace `{namespace}` with same name you defined in the earlier steps.  Replace `{suffix}` with what you observed in output from the first `kubectl` command.

The SHA of the container image should match what you'd expect.


## Delete the App CR

When you delete the CR notice how it deletes the deployment

```
kapp delete -a primes-dev -y
```


## Automation idea

If you're thinking about automating the above, then you could:

* Build app container image from source

  ```
  kp image save primes-dev \
  --git https://github.com/fastnsilver/primes \
  --git-revision {git-revision} \
  --tag {registry-domain}/apps/primes \
  --registry-ca-cert-path /home/ubuntu/.local/share/mkcert/rootCA.crt \
  --wait
  ```
  > Replace `{git-revision}` with a branch, tag or a commit SHA.  Replace `{registry-domain}` with a domain name (e.g., harbor.lab.zoolabs.me).

* Capture the image SHA from a build

  ```
  export NEW_IMAGE_SHA=$(kp build status primes-dev -b {build-number} | sed -n '1 p' | cut -d ':' -f 2- | tr -d ' ')
  ```
  > Replace `{build-number}` with an appropriate build number (e.g., 5)

* Clone the manifests repo (and place yourself in a desired branch)

  ```
  git clone https://github.com/pacphi/k8s-manifests
  cd k8s-manifests
  ```

* Fetch the original image SHA in config.yml

  ```
  yq e "select(.spec.template.spec.containers) | .spec.template.spec.containers[0].image" com/fns/primes/apps/config.yml
  ```

* Update the image SHA in config.yml

  ```
  yq e "select(.spec.template.spec.containers) | .spec.template.spec.containers[0].image = $NEW_IMAGE_SHA" -i com/fns/primes/apps/config.yml
  ```

* Commit and push the update

  ```
  git add .
  git commit -m "Update image SHA"
  git push
  ```
