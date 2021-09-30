# Installing Tanzu Build Service

This is the shortest path to install [Tanzu Build Service](https://docs.pivotal.io/build-service/1-2/installing.html) integrated with [Harbor](HARBOR.md) on a TKG workload cluster on AWS.

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
      ref: ba2dadd736b47a3e9197167500f182db483c9480
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

### Create [secret](https://docs.pivotal.io/build-service/1-2/managing-secrets.html#registry-secret) and [synced secret](https://docs.pivotal.io/build-service/1-2/synced-secrets.html)

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
harbor project create --project apps.json
harbor project list --name apps
```

### Save a container image

For example

```
kp image save primes-dev \
  --git https://github.com/fastnsilver/primes \
  --git-revision 09f83d1950c2380874b89f870ac74872dd5d7963 \
  --tag harbor.lab.zoolabs.me/apps/primes \
  --registry-ca-cert-path /home/ubuntu/.local/share/mkcert/rootCA.crt \
  --wait
```
> Consult public documentation [here](https://docs.pivotal.io/build-service/1-2/managing-images.html#save-image).