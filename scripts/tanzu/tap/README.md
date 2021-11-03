# Tanzu Application Platform Quickstart Guide

> Note that Tanzu Application Platform is in Beta.  These instructions are based upon the Beta 3 release builds.
## Create a new workload cluster

We're going to do this on AWS.

```
cat > zoolabs-app-platform.yml <<EOF
CLUSTER_NAME: zoolabs-app-platform
CLUSTER_PLAN: dev
NAMESPACE: default
CNI: antrea
IDENTITY_MANAGEMENT_TYPE: none
CONTROL_PLANE_MACHINE_TYPE: t3.large
NODE_MACHINE_TYPE: m5.xlarge
AWS_REGION: "us-west-2"
AWS_NODE_AZ: "us-west-2b"
AWS_SSH_KEY_NAME: "se-cphillipson-cloudgate-aws-us-west-2"
BASTION_HOST_ENABLED: false
ENABLE_MHC: true
MHC_UNKNOWN_STATUS_TIMEOUT: 5m
MHC_FALSE_STATUS_TIMEOUT: 12m
ENABLE_AUDIT_LOGGING: false
ENABLE_DEFAULT_STORAGE_CLASS: true
CLUSTER_CIDR: 100.96.0.0/11
SERVICE_CIDR: 100.64.0.0/13
ENABLE_AUTOSCALER: false
EOF

tanzu cluster create --file zoolabs-app-platform.yml

tanzu cluster scale zoolabs-app-platform --worker-machine-count 3
```
> Replace occurrences of `zoolabs-app-platform` above with whatever name you'd like to give the workload cluster.  You'll also want to replace the value of `AWS_SSH_KEY_NAME` with your own SSH key.  Other property values may be updated as appropriate.


Obtain the new workload cluster kubectl configuration.

```
tanzu cluster kubeconfig get zoolabs-app-platform --admin
```
> Replace occurrence of `zoolabs-app-platform` above with name you gave the workload cluster.

Sample output

```
Credentials of cluster 'zoolabs-app-platform' have been saved
You can now access the cluster by running 'kubectl config use-context zoolabs-app-platform-admin@zoolabs-app-platform'
```

## Upgrade kapp-controller

### Verify installed version

```
kubectl get deployment kapp-controller -n tkg-system -o yaml | grep kapp-controller.carvel.dev/version
```
> You should see version 0.23.0 if you've installed Tanzu Kubernetes Grid 1.4 or Tanzu Community Edition.  We need to delete this version and install a newer version of the kapp-controller.

### Install newer version

Log into management cluster

```
kubectl config use-context zoolabs-mgmt-admin@zoolabs-mgmt
```
> Replace `zoolabs-mgmt` with your own management cluster name.

Apply this patch

```
kubectl patch app/zoolabs-app-platform-kapp-controller -n default -p '{"spec":{"paused":true}}' --type=merge
```
> Replace `zoolabs-app-platform` with your own workload cluster name.

Login to workload cluster, teardown the existing kapp-controller deployment, and deploy a new version of kapp-controller.

```
kubectl config use-context zoolabs-app-platform-admin@zoolabs-app-platform
kubectl delete deployment kapp-controller -n tkg-system
kubectl apply -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/download/v0.29.0/release.yml
```
> Replace occurrence of `zoolabs-app-platform-admin@zoolabs-app-platform` with your own workload cluster context.


### Verify new release version installed

```
kubectl get deployment kapp-controller -n kapp-controller -o yaml | grep kapp-controller.carvel.dev/version
```

## Install secret-gen-controller

```
kapp deploy -y -a sg -f https://github.com/vmware-tanzu/carvel-secretgen-controller/releases/download/v0.6.0/release.yml
```

Verify install

```
kubectl get deployment secretgen-controller -n secretgen-controller -o yaml | grep secretgen-controller.carvel.dev/version
```

## Add the Tanzu Application Platform specific plugins

> This procedure expects that you want to maintain the Tanzu CLI core and plugins you installed previously for interacting with Tanzu Kubernetes Grid or Tanzu Community Edition.

You'll want to copy and save the contents of the [install-tap-plugins.sh](install-tap-plugins.sh) to the machine where you had previously installed and used the `tanzu` CLI.

```
./install-tap-plugins.sh {tanzu-network-api-token}
```
> Replace `{tanzu-network-api-token}` with a valid VMWare Tanzu Network [API Token](https://network.pivotal.io/users/dashboard/edit-profile)

## Add the Tanzu Application Platform Package Repository

Create a new namespace

```
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


Add Tanzu Application Platform package repository to the cluster by running:

```
tanzu package repository add tanzu-tap-repository \
  --url registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:0.3.0-build.6 \
  --namespace tap-install
```

Get the status of the Tanzu Application Platform package repository, and ensure the status updates to `Reconcile succeeded` by running:

```
tanzu package repository get tanzu-tap-repository --namespace tap-install
```

List the available packages by running:

```
tanzu package available list --namespace tap-install
```

List versions of available packages.  You'll want to copy and save the contents of the [list-available-packages.sh](list-available-packages.sh) to the machine where you had previously installed and used the `tanzu` CLI.

Then run:

```
./list-available-packages.sh
```

## Install a Tanzu Application Platform Profile

To view possible configuration settings, run:

```
tanzu package available get tap.tanzu.vmware.com/0.3.0-build.6 --values-schema --namespace tap-install
```
> Note that currently that the `tap.tanzu.vmware.com` package does not show all configuration settings for packages it plans to install. To find them out, look at the individual package configuration settings via same `tanzu package available get` command (e.g. for CNRs use `tanzu package available get -n tap-install cnrs.tanzu.vmware.com/1.0.3 --values-schema`). Replace dashes with underscores. For example, if the package name is `cloud-native-runtimes`, use `cloud_native_runtimes` in the `tap-values` YAML file.

Let's create a sample tap-value.yml file:

```
cat > tap-values.yml << EOF
profile: full

buildservice:
  kp_default_repository: "{container-registry-domain}/platform/app"
  kp_default_repository_username: "{container-registry-username}"
  kp_default_repository_password: "{container-registry-password}"
  tanzunet_username: "{tanzu-network-username}"
  tanzunet_password: "{tanzu-network-password}"

ootb_supply_chain_basic:
  registry:
    server: "{container-registry-domain}"
    repository: "{container-registry-domain}/platform/app"

ootb_supply_chain_testing_scanning:
  registry:
    server: "{container-registry-domain}"
    repository: "{container-registry-domain}/platform/app"

ootb_supply_chain_testing:
  registry:
    server: "{container-registry-domain}"
    repository: "{container-registry-domain}/platform/app"

learningcenter:
  # e.g. educates.example.com
  ingressDomain: "educates.{domain}"

tap_gui:
  service_type: LoadBalancer
EOF
```
> Replace curly-bracketed value-placeholders with real values. The `buildservice.kp_default_repository` and `ootb_supply_chain_*.registry.repository` values should be the same.  If you're integrating with a Harbor registry then the convention is `{harbor-domain}/{project}/{repository}`.  The `{project}` must be created and exist before you attempt the `tanzu package install` below.  The `{repository}` will be created automatically if it doesn't already exist.

Install the package by running:

```
tanzu package install tap -p tap.tanzu.vmware.com -v 0.3.0-build.6 --values-file tap-values.yml -n tap-install
```

Verify the package install by running:

```
tanzu package installed get tap -n tap-install
```

Verify all the necessary packages in the profile are installed by running:

```
tanzu package installed list -A
```

Sample output

```
ubuntu@ip-172-31-61-62:~$ tanzu package installed list -A
- Retrieving installed packages...
  NAME                                PACKAGE-NAME                                         PACKAGE-VERSION        STATUS                                                                NAMESPACE
  accelerator                         accelerator.apps.tanzu.vmware.com                    0.4.0                  Reconcile succeeded                                                   tap-install
  api-portal                          api-portal.tanzu.vmware.com                          1.0.3                  Reconcile succeeded                                                   tap-install
  appliveview                         appliveview.tanzu.vmware.com                         0.3.0-build6           Reconcile succeeded                                                   tap-install
  buildservice                        buildservice.tanzu.vmware.com                        1.3.1                  Reconcile succeeded                                                   tap-install
  cartographer                        cartographer.tanzu.vmware.com                        0.0.7                  Reconcile succeeded                                                   tap-install
  cnrs                                cnrs.tanzu.vmware.com                                1.0.3                  Reconcile succeeded                                                   tap-install
  conventions-controller              controller.conventions.apps.tanzu.vmware.com         0.4.2                  Reconcile succeeded                                                   tap-install
  developer-conventions               developer-conventions.tanzu.vmware.com               0.3.0-build.1          Reconcile succeeded                                                   tap-install
  grype                               grype.scanning.apps.tanzu.vmware.com                 1.0.0-beta.2           Reconcile succeeded                                                   tap-install
  image-policy-webhook                image-policy-webhook.signing.run.tanzu.vmware.com    1.0.0-beta.1           Reconcile succeeded                                                   tap-install
  learningcenter                      learningcenter.tanzu.vmware.com                      1.0.9-build.1          Reconcile succeeded                                                   tap-install
  learningcenter-workshops            workshops.learningcenter.tanzu.vmware.com            1.0.5-build.1          Reconcile succeeded                                                   tap-install
  ootb-supply-chain-basic             ootb-supply-chain-basic.tanzu.vmware.com             0.3.0-build.4          Reconcile succeeded                                                   tap-install
  ootb-supply-chain-testing           ootb-supply-chain-testing.tanzu.vmware.com           0.3.0-build.4          Reconcile succeeded                                                   tap-install
  ootb-supply-chain-testing-scanning  ootb-supply-chain-testing-scanning.tanzu.vmware.com  0.3.0-build.4          Reconcile succeeded                                                   tap-install
  ootb-templates                      ootb-templates.tanzu.vmware.com                      0.3.0-build.4          Reconcile succeeded                                                   tap-install
  scanning                            scanning.apps.tanzu.vmware.com                       1.0.0-beta.2           Reconcile succeeded                                                   tap-install
  service-bindings                    service-bindings.labs.vmware.com                     0.5.0                  Reconcile succeeded                                                   tap-install
  services-toolkit                    services-toolkit.tanzu.vmware.com                    0.4.0-rc.2             Reconcile succeeded                                                   tap-install
  source-controller                   controller.source.apps.tanzu.vmware.com              0.1.2                  Reconcile succeeded                                                   tap-install
  spring-boot-conventions             spring-boot-conventions.tanzu.vmware.com             0.1.2                  Reconcile succeeded                                                   tap-install
  tap                                 tap.tanzu.vmware.com                                 0.3.0-build.6          Reconcile succeeded                                                   tap-install
  tap-gui                             tap-gui.tanzu.vmware.com                             0.3.0-rc.4             Reconcile succeeded                                                   tap-install
  antrea                              antrea.tanzu.vmware.com                              0.13.3+vmware.1-tkg.1  Reconcile succeeded                                                   tkg-system
  metrics-server                      metrics-server.tanzu.vmware.com                      0.4.0+vmware.1-tkg.1   Reconcile succeeded                                                   tkg-system
```


To update all packages, run:

```
tanzu package installed update tap -v 0.3.0-build.6 --values-file tap-values.yml -n tap-install
```
> You'll need to do this when you add, adjust, or remove any key-value you specify in `tap-values.yml`.  Your mileage may vary.  The "nuclear" (and recommended) option if you're in a hurry is to just just delete the `tap` package and any lingering resources, then re-install.


## Troubleshooting a Tanzu Application Platform Profile installation

What would you do if you saw the following after executing `tanzu package installed list -A`?

```
buildservice                        buildservice.tanzu.vmware.com                        1.3.1                  Reconcile failed: Error (see .status.usefulErrorMessage for details)  tap-install
```

Start by getting more detail about the error by running:

```
tanzu package installed get buildservice -n tap-install
```

Sample output

```
ubuntu@ip-172-31-61-62:~$ tanzu package installed get buildservice -n tap-install
/ Retrieving installation details for buildservice...
NAME:                    buildservice
PACKAGE-NAME:            buildservice.tanzu.vmware.com
PACKAGE-VERSION:         1.3.1
STATUS:                  Reconcile failed: Error (see .status.usefulErrorMessage for details)
CONDITIONS:              [{ReconcileFailed True  Error (see .status.usefulErrorMessage for details)}]
USEFUL-ERROR-MESSAGE:    kapp: Error: waiting on reconcile tanzunetdependencyupdater/dependency-updater (buildservice.tanzu.vmware.com/v1alpha1) namespace: build-service:
  Finished unsuccessfully (Encountered failure condition Ready == False: CannotImportDescriptor (message:  "default" not ready: Get "https://harbor.lab.zoolabs.me/v2/": x509: certificate signed by unknown authority))
```

This is telling us that we're missing a CA.  What do we need to add to `tap-values.yml` then?

```
tanzu package available get buildservice.tanzu.vmware.com/1.3.1 --values-schema --namespace tap-install
```

Sample output

```
ubuntu@ip-172-31-61-62:~$ tanzu package available get buildservice.tanzu.vmware.com/1.3.1 --values-schema --namespace tap-install
| Retrieving package details for buildservice.tanzu.vmware.com/1.3.1...
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
tanzu package installed update tap -v 0.3.0-build.6 --values-file tap-values.yml -n tap-install
```

## How to use Tanzu Application Platform

Congratulations! You've managed to install TAP.  Now what?

// TODO


## Uninstall Tanzu Application Platform

Delete the package install

```
tanzu package installed delete tap -n tap-install -y
```
> Be patient! This can take up to 10m or more.  It may even timeout.  Just wait a little longer.  Then verify that the only two packages remaining are: `antrea` and `metrics-server` by executing `tanzu package installed list -A`.

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

## Teardown the cluster

```
tanzu cluster delete zoolabs-app-platform
kubectl config delete-context zoolabs-app-platform-admin@zoolabs-app-platform
```
> Replace occurrences of `zoolabs-app-platform` and `zoolabs-app-platform-admin@zoolabs-app-platform` with your own workload cluster name and context.


## For your consideration

* [Product page](https://tanzu.vmware.com/application-platform)
* Blogs
  * [Announcing VMware Tanzu Application Platform: A Better Developer Experience on any Kubernetes](https://tanzu.vmware.com/content/blog/announcing-vmware-tanzu-application-platform)
  * [VMware Tanzu Application Service: The Best Destination for Mission-Critical Business Apps](https://tanzu.vmware.com/content/blog/vmware-tanzu-application-service-best-mission-critical-business-apps)
  * [VMware Tanzu Application Platform Delivers a Paved Path to Production for Public Cloud and Kubernetes](https://tanzu.vmware.com/content/blog/vmware-tanzu-application-platform-beta-2-announcement)
  * [Software Supply Chain Choreography](https://tanzu.vmware.com/developer/guides/supply-chain-choreography/)
  * [Recognizing and Removing Friction Points in the Developer Experience on Kubernetes](https://tanzu.vmware.com/content/blog/removing-friction-points-developer-experience-kubernetes)
  * [Building Paths to Production with Cartographer](https://tanzu.vmware.com/content/blog/building-paths-to-production-cartographer)
* Analyst Reports
  * [VMware Tanzu Application Platform: Turning developer definition into a running Kubernetes pod](https://tanzu.vmware.com/content/vmware-tanzu-application-platform-resources/vmware-tanzu-application-platform-turning-developer-definition-into-a-running-kubernetes-pod)
* Demos
  * [VMware Tanzu Application Platform Creates a Better Developer Experience](https://www.youtube.com/watch?v=9oupRtKT_JM)
  * [VMware Tanzu Application Platform Developer Experience](https://www.youtube.com/watch?v=sMg7fg7FP28)
  * [How Tanzu Application Platform Improves the Inner Loop for Developers](https://www.youtube.com/watch?v=HDUjSSK2sdM)
* Conference sessions
  * SpringOne 2021
    * Keynote
      * [Intro](https://www.youtube.com/watch?v=2Qhj5u2bct0&t=264s)
      * [Demo](https://www.youtube.com/watch?v=2Qhj5u2bct0&t=882s)
    * Sessions
      * [Deploy Code Into Production Faster on Kubernetes](https://springone.io/2021/sessions/deploy-code-into-production-faster-on-kubernetes)
      * [Inner Loop Development with Spring Boot on Kubernetes](https://springone.io/2021/sessions/inner-loop-development-with-spring-boot-on-kubernetes)
  * VMworld 2021
    * Keynote
      * [VI3190 - DevSecOps Your Way to Any Cloud (And Delight Your Customers)](https://myevents.vmware.com/widget/vmware/vmworld2021/catalog?search=VI3190)
    * Breakout Sessions
      * [APP2479 - Introducing Tanzu Application Platform: A New Tanzu Developer Experience](https://myevents.vmware.com/widget/vmware/vmworld2021/catalog?search=APP2479)
      * [APP2482 - A developer-oriented application platform works better for ops too](https://myevents.vmware.com/widget/vmware/vmworld2021/catalog?search=APP2482)
      * [APP2109 - Steps to Implementing a More Secure Software Supply Chain in VMware Tanzu](https://myevents.vmware.com/widget/vmware/vmworld2021/catalog?search=APP2109)
      * [APP2483 - Speed the Path to Production with Application Accelerator for VMware Tanzu](https://myevents.vmware.com/widget/vmware/vmworld2021/catalog?search=APP2483)
    * Tech+ Tutorial
      * [APP2052 - Centralizing Your Software Supply Chain’s Metadata: A Key to the More Secure Software Supply Chain](https://myevents.vmware.com/widget/vmware/vmworld2021/catalog?search=APP2052)
      * [APP2089 - Building Native Spring Microservices on Kubernetes: Deep Dive](https://myevents.vmware.com/widget/vmware/vmworld2021/catalog?search=APP2089)
    * Meet the Expert
      * [APP2437 - Meet the Expert: VMware Tanzu Developer Experience](https://myevents.vmware.com/widget/vmware/vmworld2021/catalog?search=APP2437)
      * [APP2652 - Meet the Expert: Kubernetes-Centric App CI/CD](https://myevents.vmware.com/widget/vmware/vmworld2021/catalog?search=APP2652)
      * [APP2438 - Meet the Expert: Cloud Native Runtimes for VMware Tanzu](https://myevents.vmware.com/widget/vmware/vmworld2021/catalog?search=APP2438)
* Webinars
  * [No YOLO Ops: Securing the Software Supply Chain](https://tanzu.vmware.com/content/webinars/dec-3-no-yolo-ops-securing-the-software-supply-chain)
  * [So You Built a Kubernetes Platform, Now What?](https://tanzu.vmware.com/content/webinars/oct-28-so-you-built-a-kubernetes-platform-now-what-achieving-platform-economics-with-kubernetes)
* Press coverage
  * [VMware’s New Tanzu Platform Aims To Unify Kubernetes Development](https://www.infoworld.com/article/3631384/vmware-s-new-tanzu-platform-aims-to-unify-kubernetes-development.html)
  * [This too shall PaaS: VMware's new Tanzu Application Platform explained](https://www.theregister.com/2021/09/02/vmwares_new_tanzu_application_platform/)
  * [VMware Previews App Dev Platform for Kubernetes](https://containerjournal.com/editorial-calendar/vmware-previews-app-dev-platform-for-kubernetes/)
  * [VMware Tanzu Application Platform Reflects PaaS Shifts](https://myevents.vmware.com/widget/vmware/vmworld2021/catalog?search=APP2438)
