# Tanzu Application Platform Quickstart Installation Guide

> Note that Tanzu Application Platform is in Beta.  These instructions are based upon the Beta 4 release builds.

![Tanzu Application Platform // Component Diagram // Deployment Footprint // K8s Runtime Support](tap.png)


## Create a new workload cluster

Authenticate and set environment variable

```
gcloud activate-service-account --key-file=/path/to/service-account-credentials.json
```
> Update the path to the key file as appropriate

Next, we're going to use a [Terraform module](../../../../terraform/gcp/cluster/README.md) to do create the cluster.

Obtain the new workload cluster `kubectl` configuration using the scripts:

* list-clusters.sh
* set-kubectl-context.sh

## Install kapp-controller

```
kubectl apply -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/download/v0.29.0/release.yml
```

Verify install

```
kubectl get deployment kapp-controller -n kapp-controller -o yaml | grep kapp-controller.carvel.dev/version
```

## Install secret-gen-controller

```
kapp deploy -y -a sg -f https://github.com/vmware-tanzu/carvel-secretgen-controller/releases/download/v0.7.1/release.yml
```

Verify install

```
kubectl get deployment secretgen-controller -n secretgen-controller -o yaml | grep secretgen-controller.carvel.dev/version
```

## Add the Tanzu Application Platform specific plugins

> This procedure expects that you want to maintain the Tanzu CLI core and plugins you installed previously for interacting with Tanzu Kubernetes Grid or Tanzu Community Edition.

You'll want to copy and save the contents of the [install-tap-plugins.sh](../install-tap-plugins.sh) to the machine where you had previously installed and used the `tanzu` CLI.

```
./install-tap-plugins.sh {tanzu-network-api-token}
```
> Replace `{tanzu-network-api-token}` with a valid VMWare Tanzu Network [API Token](https://network.pivotal.io/users/dashboard/edit-profile).

If you need to revert back to the `v1.4.0` version, run:

```
tanzu plugin delete package
tanzu plugin install package --local {path-to-cli-directory}
```
> Replace `{path-to-cli-directory}` with a relative path to the `cli` directory that hosts the `v1.4.0` version.  If you're using a jump box, it's typically just `$HOME/cli`.


## Add the Tanzu Application Platform Package Repository

Create new namespaces

```
kubectl create ns tanzu-package-repo-global
kubectl create ns tap-install
```

Create a registry secret

```
tanzu secret registry add tap-registry \
  --username "{tanzu-network-username}" --password "{tanzu-network-password}" \
  --server registry.tanzu.vmware.com \
  --export-to-all-namespaces --yes --namespace tap-install
```
> Replace `{tanzu-network-username}` and `{tanzu-network-password}` with the account credentials that you use to authenticate to the VMware Tanzu Network.


Add the Tanzu Standard and Tanzu Application Platform package repositories to the cluster by running:

```
tanzu package repository add tanzu-standard-repository \
  --url projects.registry.vmware.com/tkg/packages/standard/repo:v1.4.0 \
  --namespace tanzu-package-repo-global

tanzu package repository add tanzu-tap-repository \
  --url registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:0.4.0-build.13 \
  --namespace tap-install
```

Get the status of the Tanzu Standard and Tanzu Application Platform package repositories, and ensure the status updates to `Reconcile succeeded` by running:

```
tanzu package repository get tanzu-standard-repository --namespace tanzu-package-repo-global
tanzu package repository get tanzu-tap-repository --namespace tap-install
```

Sample output

```
\ Retrieving repository tanzu-standard-repository...
NAME:          tanzu-standard-repository
VERSION:       8808681
REPOSITORY:    projects.registry.vmware.com/tkg/packages/standard/repo
TAG:           v1.4.0
STATUS:        Reconcile succeeded
REASON:

/ Retrieving repository tanzu-tap-repository...
NAME:          tanzu-tap-repository
VERSION:       4454281
REPOSITORY:    registry.tanzu.vmware.com/tanzu-application-platform/tap-packages
TAG:           0.4.0-build.13
STATUS:        Reconcile succeeded
REASON:
```

List the available packages by running:

```
tanzu package available list --namespace tanzu-package-repo-global
tanzu package available list --namespace tap-install
```

List versions of available packages.  You'll want to copy and save the contents of the [list-available-packages.sh](../list-available-tap-packages.sh) to the machine where you had previously installed and used the `tanzu` CLI.

Then run:

```
./list-available-tap-packages.sh
```

## Install a Tanzu Application Platform Profile

To view possible configuration settings, run:

```
tanzu package available get tap.tanzu.vmware.com/0.4.0-build.13 --values-schema --namespace tap-install
```
> Note that currently that the `tap.tanzu.vmware.com` package does not show all configuration settings for packages it plans to install. To find them out, look at the individual package configuration settings via same `tanzu package available get` command (e.g. for CNRs use `tanzu package available get -n tap-install cnrs.tanzu.vmware.com/1.1.0 --values-schema`). Replace dashes with underscores. For example, if the package name is `cloud-native-runtimes`, use `cloud_native_runtimes` in the `tap-values` YAML file.

It's helpful to start with some sample configuration, so

```
cp tap-values.yaml.sample tap-values.yaml
```

Edit the `tap-values.yaml` file by supplying appropriate configuration values; particularly occurrences of the `replace.me` placeholder.

Then, install the package by running:

```
ytt -f tap-values.yaml -f tap-config.yaml > tap-reified-values.yaml
tanzu package install tap -p tap.tanzu.vmware.com -v 0.4.0-build.13 --values-file tap-reified-values.yaml -n tap-install
```
> This will take some time.  Go grab a coffee and come back in 10 to 15 minutes.

Verify the package install by running:

```
tanzu package installed get tap -n tap-install
```
> Verify that the status for the installed package is "Reconcile succeeded".

Verify all the necessary packages in the profile are installed by running:

```
tanzu package installed list -A
```
> Sometimes the install will time out.  That's ok.  Attempt to execute the command above until you see something like the sample output below.  If any of the packages has a "Reconcile failed" you'll need to troubleshoot and fix before proceeding.  When you run the package install for TAP, it may fail fast because of sequencing.  Depending on whether you enabled ingress for your `tap-gui` configuration, `tap-gui` will require an `HttpProxy` resource, but those CRDs won’t exist until later in the process when the Cloud Native Runtimes package installs Contour.  If you're patent, everything will eventually get reconciled and figure itself out, but admittedly a fast failure is a poor experience for new users.  This is a known issue and will be addressed in a subsequent build before the official Beta 4 release.

Sample output

```
$ tanzu package installed list -A
- Retrieving installed packages...
  NAME                                PACKAGE-NAME                                         PACKAGE-VERSION  STATUS               NAMESPACE
  accelerator                         accelerator.apps.tanzu.vmware.com                    0.5.1            Reconcile succeeded  tap-install
  api-portal                          api-portal.tanzu.vmware.com                          1.0.6            Reconcile succeeded  tap-install
  appliveview                         run.appliveview.tanzu.vmware.com                     1.0.0            Reconcile succeeded  tap-install
  appliveview-conventions             build.appliveview.tanzu.vmware.com                   1.0.0            Reconcile succeeded  tap-install
  buildservice                        buildservice.tanzu.vmware.com                        1.4.0-build.1    Reconcile succeeded  tap-install
  cartographer                        cartographer.tanzu.vmware.com                        0.0.8-rc.7       Reconcile succeeded  tap-install
  cert-manager                        cert-manager.tanzu.vmware.com                        1.5.3+tap.1      Reconcile succeeded  tap-install
  cnrs                                cnrs.tanzu.vmware.com                                1.1.0            Reconcile succeeded  tap-install
  contour                             contour.tanzu.vmware.com                             1.18.2+tap.1     Reconcile succeeded  tap-install
  conventions-controller              controller.conventions.apps.tanzu.vmware.com         0.4.2            Reconcile succeeded  tap-install
  developer-conventions               developer-conventions.tanzu.vmware.com               0.4.0-build1     Reconcile succeeded  tap-install
  fluxcd-source-controller            fluxcd.source.controller.tanzu.vmware.com            0.16.0           Reconcile succeeded  tap-install
  grype                               scst-grype.apps.tanzu.vmware.com                     1.0.0            Reconcile succeeded  tap-install
  image-policy-webhook                image-policy-webhook.signing.run.tanzu.vmware.com    1.0.0-beta.2     Reconcile succeeded  tap-install
  learningcenter                      learningcenter.tanzu.vmware.com                      0.1.0-build.6    Reconcile succeeded  tap-install
  learningcenter-workshops            workshops.learningcenter.tanzu.vmware.com            0.1.0-build.7    Reconcile succeeded  tap-install
  ootb-delivery-basic                 ootb-delivery-basic.tanzu.vmware.com                 0.4.0-build.2    Reconcile succeeded  tap-install
  ootb-supply-chain-testing-scanning  ootb-supply-chain-testing-scanning.tanzu.vmware.com  0.4.0-build.2    Reconcile succeeded  tap-install
  ootb-templates                      ootb-templates.tanzu.vmware.com                      0.4.0-build.2    Reconcile succeeded  tap-install
  scanning                            scst-scan.apps.tanzu.vmware.com                      1.0.0            Reconcile succeeded  tap-install
  scst-store                          scst-store.tanzu.vmware.com                          1.0.0-beta.2     Reconcile succeeded  tap-install
  service-bindings                    service-bindings.labs.vmware.com                     0.6.0            Reconcile succeeded  tap-install
  services-toolkit                    services-toolkit.tanzu.vmware.com                    0.5.0-rc.3       Reconcile succeeded  tap-install
  source-controller                   controller.source.apps.tanzu.vmware.com              0.2.0            Reconcile succeeded  tap-install
  spring-boot-conventions             spring-boot-conventions.tanzu.vmware.com             0.2.0            Reconcile succeeded  tap-install
  tap                                 tap.tanzu.vmware.com                                 0.4.0-build.13   Reconcile succeeded  tap-install
  tap-gui                             tap-gui.tanzu.vmware.com                             1.0.0-rc.72      Reconcile succeeded  tap-install
  tap-telemetry                       tap-telemetry.tanzu.vmware.com                       0.1.0            Reconcile succeeded  tap-install
  tekton-pipelines                    tekton.tanzu.vmware.com                              0.30.0           Reconcile succeeded  tap-install
```

### Updating TAP packages

To update all packages, run:

```
tanzu package installed update tap -v 0.4.0-build.13 --values-file tap-reified-values.yaml -n tap-install
```
> You'll need to do this when you add, adjust, or remove any key-value you specify in `tap-reified-values.yaml`.  Your mileage may vary.  The "nuclear" (and recommended) option if you're in a hurry is to just just delete the `tap` package and any lingering resources, then re-install.

### Setting up Ingress

We're going to adapt the setup process to automate it even more by employing [Let's Encrypt](https://letsencrypt.org/how-it-works/), [cert-manager](https://cert-manager.io/docs/configuration/acme/dns01/google/), and [external-dns](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md) with [Contour](https://projectcontour.io/getting-started/).

TAP already installed Contour.  We can verify that API resources were created by running:

```
kubectl api-resources | grep contour
```

#### Setting up an A or CNAME record for a wildcard Domain

The `envoy` service within the `tanzu-system-ingress` namespace references an LB.

#### Install external-dns

TKG clusters include `external-dns` as part of the `tanzu-package-repo-global` namespace.  To verify this you can run:

```
tanzu package available list external-dns.tanzu.vmware.com -n tanzu-package-repo-global
```

Sample output

```
$ tanzu package available list external-dns.tanzu.vmware.com -n tanzu-package-repo-global
- Retrieving package versions for external-dns.tanzu.vmware.com...
  NAME                           VERSION               RELEASED-AT
  external-dns.tanzu.vmware.com  0.8.0+vmware.1-tkg.1  2021-06-11 11:00:00 -0700 PDT
```

We can check in on what we can configure

```
tanzu package available get external-dns.tanzu.vmware.com/0.8.0+vmware.1-tkg.1 --values-schema --namespace tanzu-package-repo-global
```

Let's install the external-dns package with a [script](install-external-dns-package-on-gke.sh)

```
./install-external-dns-package-on-gke.sh {project-id} {service-account-key-path-to-file-in-json-format} {domain}
```
> This script simplifies the process of configuring and installing external-dns on your GKE cluster.

#### Manual DNS

If you chose not to install `external-dns`, then you will have to [manually add](https://cloud.google.com/dns/docs/records) a wildcard domain as an `A` or `CNAME` record to the zone within Cloud DNS.

#### Install a Let's Encrypt managed Certificate

> Use this option only when the container image registry you're interacting with has been configured to trust the same CA via Let's Encrypt.

We'll create a [ClusterIssuer](https://cert-manager.io/docs/concepts/issuer/) and [Certificate](https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/), and [Secret](https://kubernetes.io/docs/concepts/configuration/secret/) on a TKG cluster on AWS where `cert-manager` is already installed.

```
./install-letsencrypt-cert-on-gke.sh {email-address} {project-id} {service-account-key-path-to-file-in-json-format} {domain}
```
> This script also makes use of [kubernetes-reflector](https://github.com/emberstack/kubernetes-reflector#cert-manager-support) to automatically mirror the `tls` secret in the `contour-tls` namespace into the `learningcenter` namespace.

#### Create a new Tanzu Application Platform GUI catalog

We're going to fetch some [baseline configuration](https://network.pivotal.io/products/tanzu-application-platform/#/releases/1009773) for a _blank catalog_ from the Tanzu Network.

```
./fetch-tap-gui-catalog.sh {tanzu-network-api-token}
```
> Replace `{tanzu-network-api-token}` with a valid VMware Tanzu Network account [API Token](https://network.pivotal.io/users/dashboard/edit-profile).

Then we'll create a new Git repository to host the catalog.  (In this example we'll use Github, but you could target any git-compatible repository provider).

```
cd /tmp
tar xvf tap-gui-blank-catalog.tgz
cd blank
git init
gh repo create tap-gui-catalog
git branch -m master main
git add .
git status
git commit -m "Initial commit"
git push -u origin main --force
```


#### Verify Contour HTTP proxies

Finally we can execute:

```
kubectl get httpproxy -A
```

to see all of the HTTPS endpoints for the TAP components

Sample output

```
$ kubectl get httpproxy -A
NAMESPACE   NAME      FQDN                      TLS SECRET        STATUS   STATUS DESCRIPTION
tap-gui     tap-gui   tap-gui.j00k.ironleg.me   contour-tls/tls   valid    Valid HTTPProxy
```

### Installing the Visual Studio Code TAP Extension

You may use the convenience script to download a `.vsix` file for installation as an extension to [VSCode](https://code.visualstudio.com/).

```
./fetch-tap-vscode-extension.sh {tanzu-network-api-token}
```
> Replace `{tanzu-network-api-token}` with a valid VMWare Tanzu Network [API Token](https://network.pivotal.io/users/dashboard/edit-profile)


## Troubleshooting a Tanzu Application Platform Profile installation

### Problem with build-service

What would you do if you saw the following after executing `tanzu package installed list -A`?

```
buildservice                        buildservice.tanzu.vmware.com                        1.4.0-build.1                    Reconcile failed: Error (see .status.usefulErrorMessage for details)  tap-install
```

Start by getting more detail about the error by running:

```
tanzu package installed get buildservice -n tap-install
```

Sample output

```
$ tanzu package installed get buildservice -n tap-install
/ Retrieving installation details for buildservice...
NAME:                    buildservice
PACKAGE-NAME:            buildservice.tanzu.vmware.com
PACKAGE-VERSION:         1.4.0-build.1
STATUS:                  Reconcile failed: Error (see .status.usefulErrorMessage for details)
CONDITIONS:              [{ReconcileFailed True  Error (see .status.usefulErrorMessage for details)}]
USEFUL-ERROR-MESSAGE:    kapp: Error: waiting on reconcile tanzunetdependencyupdater/dependency-updater (buildservice.tanzu.vmware.com/v1alpha1) namespace: build-service:
  Finished unsuccessfully (Encountered failure condition Ready == False: CannotImportDescriptor (message:  "default" not ready: Get "https://harbor.lab.zoolabs.me/v2/": x509: certificate signed by unknown authority))
```

This is telling us that we're missing a CA.  What do we need to add to `tap-values.yml` then?

```
tanzu package available get buildservice.tanzu.vmware.com/1.4.0-build.1 --values-schema --namespace tap-install
```

Sample output

```
$ tanzu package available get buildservice.tanzu.vmware.com/1.4.0-build.1 --values-schema --namespace tap-install
| Retrieving package details for buildservice.tanzu.vmware.com/1.4.0-build.1...
  KEY                             DEFAULT  TYPE    DESCRIPTION
  kp_default_repository           <nil>    string  docker repository (required)
  kp_default_repository_password  <nil>    string  registry password (required)
  kp_default_repository_username  <nil>    string  registry username (required)
  tanzunet_password               <nil>    string  tanzunet registry password (required for dependency updater feature)
  tanzunet_username               <nil>    string  tanzunet registry username (required for dependency updater feature)
  ca_cert_data                    <nil>    string  tbs registry ca certificate (used for self signed registry)
```

So we'll need to add a child property key named `ca_cert_data:` and an associated multi-line value underneath `buildservice:`.

Then run:

```
tanzu package installed update tap -v 0.4.0-build.13 --values-file tap-values.yml -n tap-install
```

### Problem with tap-gui

Maybe you notice that the _Tanzu Application Platform GUI_ is missing an entry for the application you just deployed?

* Did you [install the blank catalog](#create-a-new-tanzu-application-platform-gui-catalog)?
* Did you [add an entry to catalog-info.yaml](USAGE.md#getting-your-app-to-appear-in-the-tanzu-application-platform-gui-catalog)?
* Is your entry referencing the correct branch and file? (e.g., a Github URL might look like `https://github.com/{owner-or-organization}/{project}/blob/{branch}/{filename}`)

Verify that the _app-config_ version has your updates.

```
kubectl get secrets -n tap-gui
kubectl get secret app-config-ver-{version} -n tap-gui -o "jsonpath={.data.app-config\.yaml}" | base64 -d
```
> Replace `{version}` above with the latest version of the secret available

If not, try

```
kubectl delete po -l component=backstage-server -n tap-gui
```

Then wait ~ 2 minutes and re-verify.


## Uninstall Tanzu Application Platform

Delete the package install

```
tanzu package installed delete tap -n tap-install -y
```
> Be patient! This can take up to 10m or more.  It may even timeout.  Just wait a little longer.  Then verify that no packages are installed by executing `tanzu package installed list -A`.

Delete lingering resources

```
kubectl delete secret tap-tap-install-values -n tap-install
kubectl delete sa tap-tap-install-sa -n tap-install
kubectl delete clusterroles.rbac.authorization.k8s.io tap-tap-install-cluster-role
kubectl delete clusterrolebindings.rbac.authorization.k8s.io tap-tap-install-cluster-rolebinding
```

Delete the package repository

```
tanzu package repository delete tanzu-tap-repository -n tap-install
```


## Uninstall external-dns

Run this [script](uninstall-external-dns-package-on-gke.sh)

```
./uninstall-external-dns-package-on-gke.sh
```


## Uninstall the Let's Encrypt managed certificate

Run this [script](uninstall-letsencrypt-cert-on-gke.sh)

```
./uninstall-letsencrypt-cert-on-gke.sh
```


## Teardown the cluster

Use the [Terraform module](../../../../terraform/gcp/cluster/README.md) to do destroy the cluster.

```
kubectl config get-contexts
kubectl config delete-context {context}
```
> Replace occurrence of `{context}` with your own workload cluster context.

