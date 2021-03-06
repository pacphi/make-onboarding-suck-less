# Installing Tanzu Build Service

This is the shortest path to install [Tanzu Build Service](https://docs.vmware.com/en/Tanzu-Build-Service/1.3/vmware-tanzu-build-service-v13/GUID-installing.html) integrated with [Harbor](../../harbor/README.md) on a TKG workload cluster on AWS.

Fetch documentation and scripts

```
cat > vendir.yml <<EOF
apiVersion: vendir.k14s.io/v1alpha1
kind: Config
directories:
- path: vendor
  contents:
  - path: .
    git:
      url: https://github.com/pacphi/tf4k8s
      ref: 4e45c767ba4ed0d4fa1218cc6626b4aec329e559
    includePaths:
    - experiments/k8s/tbs/*.sh
EOF

vendir sync
```

Change directories

```
cd vendor/experiments/k8s/tbs
```

Visit https://github.com/pacphi/tf4k8s/tree/master/experiments/k8s/tbs in your favorite browser.

You've got the scripts!  Follow the instructions.


## Post-installation steps

### Create [secret](https://docs.vmware.com/en/Tanzu-Build-Service/1.3/vmware-tanzu-build-service-v13/GUID-managing-secrets.html#create-an-artifactory-harbor-or-acr-registry-secret) and [synced secret](https://docs.vmware.com/en/Tanzu-Build-Service/1.3/vmware-tanzu-build-service-v13/GUID-synced-secrets.html)

```
kp secret create registry-credentials --registry {registry-domain} --registry-user {registry-username}

kubectl create secret generic registry-credentials-synced --from-file=.dockerconfigjson=$HOME/.docker/config.json --type=kubernetes.io/dockerconfigjson -n build-service

kubectl label secret registry-credentials-synced com.vmware.tanzu.buildservice.sync="true" -n build-service
```

### Create new project

```
mkdir $HOME/.harbor
wget https://github.com/hinyinlam-pivotal/cli-for-harbor/releases/download/v0.5/harbor-cli-0.0.1-SNAPSHOT.jar
mv harbor-cli-0.0.1-SNAPSHOT.jar $HOME/.harbor
alias harbor="java -jar $HOME/.harbor/harbor-cli-0.0.1-SNAPSHOT.jar"
harbor login --username {harbor-username} --password '{harbor-password}' --api {harbor-hostname}
cat > hp.json <<EOF
{ "projectName": "apps", "public": false }
EOF
harbor project create --project hp.json
harbor project list --name apps
```

### Save a container image

#### For example

```
kp image save primes-dev \
  --git https://github.com/fastnsilver/primes \
  --git-revision 5b07f16024a92ec4a211e1307393db7da0d7387e \
  --tag harbor.lab.zoolabs.me/apps/primes \
  --registry-ca-cert-path /home/ubuntu/.local/share/mkcert/rootCA.crt \
  --wait
```
> Consult public documentation [here](https://docs.pivotal.io/build-service/1-2/managing-images.html#save-image).

Console output should end with something like the following

```
Saving harbor.lab.zoolabs.me/apps/primes...
*** Images (sha256:9d06cbf458794d3b652501db72d4a364bbec44442bc6b47622501962ae000656):
      harbor.lab.zoolabs.me/apps/primes
      harbor.lab.zoolabs.me/apps/primes:b5.20211007.123122
Reusing cache layer 'paketo-buildpacks/bellsoft-liberica:jdk'
Adding cache layer 'paketo-buildpacks/gradle:application'
Adding cache layer 'paketo-buildpacks/gradle:cache'
```

Make a note of the image SHA.


#### Other examples

> Replace occurrences of `harbor.klu.zoolabs.me/platform/app` below wth your own container image registry / repository prefix.

* VueJS with NPM

  ```
  kp image save vue-sample --git https://github.com/paketo-buildpacks/samples --sub-path nodejs/vue-npm --tag harbor.klu.zoolabs.me/platform/app/vue-sample --env "BP_NODE_RUN_SCRIPTS=build" --env "NODE_ENV=development" --wait
  ```

* React with YARN

  ```
  kp image save react-sample --git https://github.com/paketo-buildpacks/samples --sub-path nodejs/react-yarn --tag harbor.klu.zoolabs.me/platform/app/react-sample --env "BP_NODE_RUN_SCRIPTS=build" --wait
  ```

* Angular with NPM

  ```
  kp image save angular-sample --git https://github.com/paketo-buildpacks/samples --sub-path nodejs/angular-npm --tag harbor.klu.zoolabs.me/platform/app/angular-sample --env "BP_NODE_RUN_SCRIPTS=build" --env "NODE_ENV=development" --wait
  ```

* httpd

  ```
  kp image save httpd-sample --git https://github.com/paketo-buildpacks/samples --sub-path httpd/httpd-sample --tag harbor.klu.zoolabs.me/platform/app/httpd-sample --cluster-builder custom --wait
  ```

* Python with PIP

  ```
  kp image save python-sample --git https://github.com/paketo-buildpacks/samples --sub-path python/pip --tag harbor.klu.zoolabs.me/platform/app/python-sample --wait
  ```

* Procfile

  ```
  kp image save procfile-sample --git https://github.com/paketo-buildpacks/samples --sub-path procfile/procfile-sample --tag harbor.klu.zoolabs.me/platform/app/procfile-sample --wait
  ```