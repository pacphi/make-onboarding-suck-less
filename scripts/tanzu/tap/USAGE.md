# Tanzu Application Platform Quickstart Usage Guide

## Accelerators, increasing development velocity

What are accelerators?  An accelerator is essentially comprised of a _template_ (e.g., initial source code and configuration) for creating a cloud-native application compliant with an enterprise's governance standards and a _workload_ custom resource definition for interfacing with Tanzu Application Platform.  This allows developers to ignore Dockerfiles or other Kubernetes resources that have dependencies on the target application infrastructure.

Let's see what accelerators are available:

```
tanzu accelerators list
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
tanzu apps workload create my-java-web-app --git-repo https://github.com/pacphi/my-java-web-app --git-branch main
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

// FIXME Need to figure out how to pass credentials for publishing image to Harbor private registry.


Congratulations! Your first workload has been built, packaged as a container image, published to Harbor, then deployed to a target cluster.

// TODO Document other use cases

* How to update existing workloads
* Inner loop development with Tanzu Developer Tools
* How to make use of Tanzu Application Platform GUI
* How to make use of Application Live View
* A tidbit on how to provision/onboard Educates workshops