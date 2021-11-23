# Tanzu Application Platform Quickstart Usage Guide

## Prerequisites

As a developer you're going to want to have a few tools installed on your workstation.  At a minimum:

* [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) CLI
  * Your kubeconfig context is set to the prepared cluster `kubectl config use-context {CONTEXT_NAME}`.  Replace `{CONTEXT_NAME}` with the context for the cluster you wish to target.
  * By the way, that cluster should have the Tanzu Application Platform installed on it.
* [tanzu](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-install-cli.html#download-and-unpack-the-tanzu-cli-and-kubectl-1) CLI
  * The `apps` plugin is installed. See the [Apps Plugin Overview](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/0.3/tap-0-3/GUID-cli-plugins-apps-overview-installation.html#Installation).
* This Visual Studio Code [extension](INSTALL.md#installing-the-visual-studio-code-tap-extension)
* Ask your platform operator to create a new namespace on the target cluster for your workloads to run within.
  * This handy [script](setup-developer-namespace.sh) must be run in advance.  Or refer to these [instructions](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/0.3/tap-0-3/GUID-install-components.html#set-up-developer-namespaces-to-use-installed-packages-30).

## Accelerators, increasing development velocity

What are accelerators?  An accelerator is essentially comprised of a _template_ (e.g., initial source code and configuration) for creating a cloud-native application compliant with an enterprise's governance standards and a _workload_ custom resource definition for interfacing with Tanzu Application Platform.  This allows developers to ignore Dockerfiles or other Kubernetes resources that have dependencies on the target application infrastructure.

Let's see what accelerators are available:

```
tanzu accelerator list
```

Sample output

```
$ tanzu accelerator list

NAME                       READY   REPOSITORY
hello-fun                  true    git-repository: https://github.com/sample-accelerators/hello-fun:tap-beta3
hello-ytt                  true    git-repository: https://github.com/sample-accelerators/hello-ytt:tap-beta3
new-accelerator            true    git-repository: https://github.com/sample-accelerators/new-accelerator:tap-beta3
node-express               true    git-repository: https://github.com/sample-accelerators/node-express:tap-beta3
spring-petclinic           true    git-repository: https://github.com/sample-accelerators/spring-petclinic:tap-beta3
spring-sql-jpa             true    git-repository: https://github.com/sample-accelerators/spring-sql-jpa:tap-beta3
tanzu-java-web-app         true    git-repository: https://github.com/sample-accelerators/tanzu-java-web-app.git:tap-beta3
weatherforecast-csharp     true    git-repository: https://github.com/sample-accelerators/csharp-weatherforecast.git:tap-beta3
weatherforecast-fsharp     true    git-repository: https://github.com/sample-accelerators/fsharp-weatherforecast.git:tap-beta3
weatherforecast-steeltoe   true    git-repository: https://github.com/sample-accelerators/steeltoe-weatherforecast.git:tap-beta3
```

What if we want to create a new application based on one of the above?

```
tanzu accelerator generate tanzu-java-web-app --server-url https://accelerator.{domain} --options '{"projectName":"{application-name}"}'
```

Sample output

```
$ cd /tmp
$ tanzu accelerator generate tanzu-java-web-app --server-url https://accelerator.lab.zoolabs.me --options '{"projectName":"my-java-web-app"}'
zip file my-java-web-app.zip created
```
> This will download a zip file containing the source code and configuration for the new project named `my-java-web-app` into the directory where the command was executed.

Let's unpack what we downloaded and explore

```
unzip -o unzip -o my-java-web-app.zip
cd my-java-web-app
ls -la
```
> Note that this is a Java application built with [Maven](https://maven.apache.org/).  In the top-level folder you'll see a `config` directory plus a couple files: `catalog-info.yaml` and `Tiltfile`.  The config directory contains the [Workload](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/0.3/tap-0-3/GUID-cli-plugins-apps-command-reference-tanzu_apps_workload.html) custom resource definition.  The `Tiltfile` is used by the [Tanzu Developer Tools Visual Studio Code extension](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/0.3/tap-0-3/GUID-vscode-extension-about.html) to help you with inner-loop development (e.g., build, run, test on your local workstation).  The `catalog-info.yaml` file is consumed by [Tanzu Application Platform GUI](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/0.3/tap-0-3/GUID-tap-gui-catalog-catalog-operations.html)'s Organization Catalog.

## Prepare new project repository

Ultimately what you'd want is for this (or any) project to be managed in a distributed source control repository, because you're on a product team, and you'll all collaborate to add new features or fix defects over time.  So let's prepare a repository and get this project's source pushed.  (In this example we'll use Github, but you could target any git-compatible repository provider).

```
git init
gh repo create
git branch -m master main
git add .
git status
git commit -m "Initial commit"
git push -u origin main
```
> Assumes you have both the [git](https://git-scm.com/downloads) and [gh](https://github.com/cli/cli#installation) CLI installed, and that you have [authenticated](https://cli.github.com/manual/gh_auth_login) to Github.

Sample interaction

```
❯ git init
hint: Using 'master' as the name for the initial branch. This default branch name
hint: is subject to change. To configure the initial branch name to use in all
hint: of your new repositories, which will suppress this warning, call:
hint:
hint:   git config --global init.defaultBranch <name>
hint:
hint: Names commonly chosen instead of 'master' are 'main', 'trunk' and
hint: 'development'. The just-created branch can be renamed via this command:
hint:
hint:   git branch -m <name>
Initialized empty Git repository in /tmp/my-java-web-app/.git/
❯ gh repo create
? Repository name my-java-web-app
? Repository description Sample Java Web App based on a Tanzu Application Platform Accelerator
? Visibility Public
? This will add an "origin" git remote to your local repository. Continue? Yes
✓ Created repository pacphi/my-java-web-app on GitHub
✓ Added remote https://github.com/pacphi/my-java-web-app.git
❯ git branch -m master main
❯ git add .
❯ git status
On branch main

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
        new file:   .gitignore
        new file:   .mvn/wrapper/MavenWrapperDownloader.java
        new file:   .mvn/wrapper/maven-wrapper.jar
        new file:   .mvn/wrapper/maven-wrapper.properties
        new file:   .tanzu/tanzu_tilt_extensions.py
        new file:   .tanzu/wait.sh
        new file:   LICENSE
        new file:   README.md
        new file:   Tiltfile
        new file:   accelerator-log.md
        new file:   catalog-info.yaml
        new file:   config/workload.yaml
        new file:   mvnw
        new file:   mvnw.cmd
        new file:   pom.xml
        new file:   src/main/java/com/example/springboot/Application.java
        new file:   src/main/java/com/example/springboot/HelloController.java
        new file:   src/main/resources/application.yml
        new file:   src/test/java/com/example/springboot/HelloControllerTest.java
❯ git commit -m "Initial commit"
[main (root-commit) 4c2c32d] Initial commit
 19 files changed, 1272 insertions(+)
 create mode 100644 .gitignore
 create mode 100644 .mvn/wrapper/MavenWrapperDownloader.java
 create mode 100644 .mvn/wrapper/maven-wrapper.jar
 create mode 100644 .mvn/wrapper/maven-wrapper.properties
 create mode 100644 .tanzu/tanzu_tilt_extensions.py
 create mode 100755 .tanzu/wait.sh
 create mode 100644 LICENSE
 create mode 100644 README.md
 create mode 100644 Tiltfile
 create mode 100644 accelerator-log.md
 create mode 100644 catalog-info.yaml
 create mode 100644 config/workload.yaml
 create mode 100755 mvnw
 create mode 100644 mvnw.cmd
 create mode 100644 pom.xml
 create mode 100644 src/main/java/com/example/springboot/Application.java
 create mode 100644 src/main/java/com/example/springboot/HelloController.java
 create mode 100644 src/main/resources/application.yml
 create mode 100644 src/test/java/com/example/springboot/HelloControllerTest.java
 ❯ git push -u origin main
Enumerating objects: 37, done.
Counting objects: 100% (37/37), done.
Delta compression using up to 12 threads
Compressing objects: 100% (27/27), done.
Writing objects: 100% (37/37), 60.97 KiB | 8.71 MiB/s, done.
Total 37 (delta 0), reused 0 (delta 0), pack-reused 0
To https://github.com/pacphi/my-java-web-app.git
 * [new branch]      main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.
```

## Update workload CRD

Inspect the content of `workload.yaml`:

```
cat config/workload.yaml
```
> Note the value of `spec.source.git.url`. You're going to update this value to be the git repository you just pushed.

Update the repo value:

```
cd config
sed -i 's/sample-accelerators/pacphi/g' workload.yaml
cd ..
```
> Note [sed](https://www.gnu.org/software/sed/manual/sed.html) is used to replace the owner of the `github.com` repository above; don't blindly follow, make sure you edit the value of `spec.source.git.url` so that it references your own git repository.

Commit and push this change:

```
git add .
git status
git commit -m "Update workload.yaml source repository"
git push -u origin main
```

## Build, package, and deploy workload to a target cluster

How do we build, package and deploy this application? I'm glad you asked.

```
tanzu apps workload create my-java-web-app --git-repo https://github.com/pacphi/my-java-web-app --git-branch main --type web
```
> Replace the values for the parameters `--git-repo` and `--git-branch` above with your own.

Sample interaction

```
$ tanzu apps workload create my-java-web-app --git-repo https://github.com/pacphi/my-java-web-app --git-branch main --type web

Create workload:
      1 + |apiVersion: carto.run/v1alpha1
      2 + |kind: Workload
      3 + |metadata:
      4 +   |  labels:
      5 + |    apps.tanzu.vmware.com/workload-type: web
      6 + |  name: my-java-web-app
      7 + |  namespace: default
      8 + |spec:
      9 + |  source:
     10 + |    git:
     11 + |      ref:
     12 + |        branch: main
     13 + |      url: https://github.com/pacphi/my-java-web-app

? Do you want to create this workload? Yes
```

To watch the progress of your request:

```
tanzu apps workload tail my-java-web-app --since 10m --timestamp
```
> Type `Ctrl+c` to exit.

Congratulations! Your first workload has been built, packaged as a container image, published to Harbor, then deployed to a target cluster.

> This should get you asking the question: "Could I migrate an existing application?"


## Troubleshooting stalled workload deployments

The first place you may want to look is the `pod` where the build is happening. If you were attempting to deploy `my-java-web-app`, then you could execute:

```
kubectl describe po -l image.kpack.io/image=my-java-web-app
```

If you see something like...

```
Warning  Failed     4m40s (x3 over 5m21s)  kubelet            Failed to pull image "harbor.lab.zoolabs.me/platform/app:clusterbuilder-default@sha256:03925d11c7b1d5ea66079101edc153dfb645d1f13e837196eb9b211ff9064da3": rpc error: code = Unknown desc = failed to pull and unpack image "harbor.lab.zoolabs.me/platform/app@sha256:03925d11c7b1d5ea66079101edc153dfb645d1f13e837196eb9b211ff9064da3": failed to resolve reference "harbor.lab.zoolabs.me/platform/app@sha256:03925d11c7b1d5ea66079101edc153dfb645d1f13e837196eb9b211ff9064da3": failed to do request: Head "https://harbor.lab.zoolabs.me/v2/platform/app/manifests/sha256:03925d11c7b1d5ea66079101edc153dfb645d1f13e837196eb9b211ff9064da3": x509: certificate signed by unknown authority
```

...in the output, then you need to talk to your platform operator.  Some configuration needs to be addressed in the Tanzu Application Platform installation.

> If your platform operator had provisioned a workload cluster to [trust a custom CA](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-cluster-lifecycle-secrets.html#custom-ca) then if there are any discrepancies between CA for your container registry you may run into this problem.  Typically a problem when employing a self-signed certificate.

## List workloads

```
tanzu apps workload list
```


## Get details for a workload

```
tanzu app workload get {app-name}
```

Sample interaction

```
$ tanzu apps workload get my-java-web-app

# my-java-web-app: Ready
---
lastTransitionTime: "2021-11-16T19:27:43Z"
message: ""
reason: Ready
status: "True"
type: Ready

Workload pods
NAME                                STATE       AGE
my-java-web-app-build-1-build-pod   Succeeded   8m34s

Workload Knative Services
NAME              READY   URL
my-java-web-app   Ready   http://my-java-web-app-default.klu.zoolabs.me
```

> Go visit that URL in your favorite browser.  Notice that the first request takes a little more time to return a response.  This is is because the app instance, when not receiving requests, will scale to zero.  This is an in-built benefit of [KNative serving](https://knative.dev/docs/serving/autoscaling/scale-to-zero/) and [Cloud Native Runtimes](https://docs.vmware.com/en/Cloud-Native-Runtimes-for-VMware-Tanzu/1.0/tanzu-cloud-native-runtimes-1-0/GUID-cnr-overview.html).


## Update workload

```
tanzu app workload update --help
```
> Gets you help for all the options available to you for updating your workload.

## Delete workload(s)

```
tanzu apps workload delete --all -n {namespace}
```
> Delete all workloads within the `{namespace}`.  Replace `{namespace}` with an actual namespace name.

Sample interaction

```
$ tanzu apps workload delete --all -n default
? Really delete all workloads in the namespace "default"? Yes

Deleted workloads in namespace "default"
```

```
tanzu apps workload delete -f {path-to-workload-yaml-file}
```
> Deletes a single workload.  Replace `{path-to-workload-yaml-file}` with an actual path to a `workload.yaml` file.


## Getting your app to appear in the Tanzu Application Platform GUI Catalog

Visit the Git repository containing the contents of the _blank catalog_ you [created earlier](INSTALL.md#create-a-new-tanzu-application-platform-gui-catalog) using your favorite browser.

You'll want to edit and add an entry to `catalog-info.yaml` for each application deployed with `tanzu apps workload create`.

Have a look at this sample repository's [catalog-info.yaml](https://github.com/pacphi/tap-gui-catalog/blob/main/catalog-info.yaml) file for an example of what an entry looks like.

> The default catalog refresh is 200 seconds.  After your catalog refreshes you can see the entry in the catalog and interact with it.


## Other examples

* [Dotnet Core](https://github.com/pacphi/AltPackageRepository)
  * Deploy with

    ```
    tanzu apps workload create dotnet-core-sample --git-repo https://github.com/pacphi/AltPackageRepository --git-branch main --type web
    ```
* [Ruby](https://github.com/pacphi/puma-sample)
  * Tanzu Application Platform does not ship with commercial support for _Ruby_, but we can
    * (a) install OSS _buildpack_

      ```
      kp clusterstore add default -b gcr.io/paketo-buildpacks/ruby
      ```

    * (b) install a custom _clusterbuilder_

      ```
      kubectl apply -f custom-cb.yaml
      ```
      > See [custom-cb.yaml](custom-cb.yaml)

    * (c) update configuration in `/tmp/tap-values-updated.yaml`

      replacing

      ```
      ootb_supply_chain_basic:
        registry:
          server: "harbor.{domain}"
          repository: "platform/app"
      ```

      with

      ```
      ootb_supply_chain_basic:
        cluster_builder: custom
        registry:
          server: "harbor.{domain}"
          repository: "platform/app"
      ```

    * (d) Update the installed package

      ```
      tanzu package installed update tap -v 0.3.0 --values-file /tmp/tap-values-updated.yml -n tap-install
      ```

  * Deploy with

    ```
    tanzu apps workload create puma --git-repo https://github.com/pacphi/puma-sample --git-branch main --type web
    ```

* [Go](https://github.com/pacphi/go-gin-web-server)
  * Deploy with

    ```
    tanzu apps workload create go-sample --git-repo https://github.com/pacphi/go-gin-web-server --git-branch master --type web
    ```

## Known Issues

Cannot deploy an application with `--image` flag

```
  tanzu apps workload create {workload-name} --image harbor.{domain}/platform/app/{workload-name}:{version}
$ tanzu apps workload get {workload-name}

# puma: TemplateStampFailure
---
lastTransitionTime: "2021-11-22T05:37:00Z"
message: "unable to stamp object for resource 'source-provider': unable to apply ytt
  template: ytt: Error: \n- struct has no .source field or method\n    in <toplevel>\n
  \     stdin.yml:3 | #@ if hasattr(data.values.workload.spec.source, \"git\"):\n"
reason: TemplateStampFailure
status: "False"
type: Ready
```


## To do

* [ ] Inner loop development with Tanzu Developer Tools Visual Studio Code extension
* [ ] How to make use of Tanzu Application Platform GUI
* [ ] How to make use of Application Live View
* [ ] How to work with service bindings
* [ ] How to disable scale to zero
* [ ] How to provision/onboard Educates workshops