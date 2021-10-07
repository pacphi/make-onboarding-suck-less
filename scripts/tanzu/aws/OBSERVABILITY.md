# Observability, Metrics and Call Tracing for Microservices

Identify and target a workload cluster.

If your workload cluster is registered or attached with Tanzu Mission Control, then [integrate](https://docs.wavefront.com/integrations_tmc_howto.html) it with Tanzu Observability.


## (Optionally) Fetch the source

```
git clone https://github.com/pacphi/tut-metrics-and-tracing
```


## Publish images

### Client

```
kp image save client \
  --git https://github.com/pacphi/tut-metrics-and-tracing \
  --sub-path basic/client \
  --git-revision ca56801fdfeb23dba99d8fa876c34a7c3c6b3379 \
  --tag harbor.lab.zoolabs.me/apps/client \
  --registry-ca-cert-path /home/ubuntu/.local/share/mkcert/rootCA.crt \
  --env BP_JVM_VERSION=17 \
  --wait
```
> You will want to update the `--tag` and `--registry-ca-cert-path` values according to your particular setup.

Tail end of sample output

```
Saving harbor.lab.zoolabs.me/apps/client...
*** Images (sha256:284e6440b5596de5f9aa290d14fae4e05fa692b4d0702c1f068481edb707f2b2):
      harbor.lab.zoolabs.me/apps/client
      harbor.lab.zoolabs.me/apps/client:b2.20211007.161120
Adding cache layer 'paketo-buildpacks/bellsoft-liberica:jdk'
Adding cache layer 'paketo-buildpacks/maven:application'
Adding cache layer 'paketo-buildpacks/maven:cache'
Adding cache layer 'paketo-buildpacks/maven:maven'
===> COMPLETION
Build successful
```

### Server

```
kp image save server \
  --git https://github.com/pacphi/tut-metrics-and-tracing \
  --sub-path basic/service \
  --git-revision ca56801fdfeb23dba99d8fa876c34a7c3c6b3379 \
  --tag harbor.lab.zoolabs.me/apps/server \
  --registry-ca-cert-path /home/ubuntu/.local/share/mkcert/rootCA.crt \
  --env BP_JVM_VERSION=17 \
  --wait
```
> Again, you will want to update the `--tag` and `--registry-ca-cert-path` values according to your particular setup.

Tail end of sample output

```
Saving harbor.lab.zoolabs.me/apps/server...
*** Images (sha256:cbef49101d21b5e978a268559ce5b8167b42f9cdaad3d0a1fe8f0411cecdb2e3):
      harbor.lab.zoolabs.me/apps/server
      harbor.lab.zoolabs.me/apps/server:b1.20211007.161445
Adding cache layer 'paketo-buildpacks/bellsoft-liberica:jdk'
Adding cache layer 'paketo-buildpacks/maven:application'
Adding cache layer 'paketo-buildpacks/maven:cache'
Adding cache layer 'paketo-buildpacks/maven:maven'
===> COMPLETION
Build successful
```


## Update the manifests

We're going to use the same `k8s-manifests` [repository](https://github.com/pacphi/k8s-manifests) we did for the `primes` application.

You'll want to fork and clone the aforementioned repository.  Then update the image SHAs in each of the `client` and `server` directory's `config.yml` files.


## Setup up continuous deployment

### Client

```
cat > console-availability-client-cd-via-gitrepo.yml <<EOF
apiVersion: kappctrl.k14s.io/v1alpha1
kind: App
metadata:
  name: console-availability-client
  namespace: {namespace}
spec:
  serviceAccountName: {namespace}-ns-sa
  fetch:
  - git:
      url: https://github.com/pacphi/k8s-manifests
      ref: origin/main
      subPath: com/vmware/console-availability/client/{namespace}
  template:
  - ytt: {}
  deploy:
  - kapp: {}
EOF
```
> Replace occurrences of `{namespace}` with the namespace you want to deploy an instance of the client into.

```
kapp deploy -a console-availability-client -f console-availability-client-cd-via-gitrepo.yml -y
```

### Server

```
cat > console-availability-server-cd-via-gitrepo.yml <<EOF
apiVersion: kappctrl.k14s.io/v1alpha1
kind: App
metadata:
  name: console-availability-server
  namespace: {namespace}
spec:
  serviceAccountName: {namespace}-ns-sa
  fetch:
  - git:
      url: https://github.com/pacphi/k8s-manifests
      ref: origin/main
      subPath: com/vmware/console-availability/server/{namespace}
  template:
  - ytt: {}
  deploy:
  - kapp: {}
EOF
```
> Replace occurrences of `{namespace}` with the namespace you want to deploy an instance of the server into.

```
kapp deploy -a console-availability-server -f console-availability-server-cd-via-gitrepo.yml -y
```
