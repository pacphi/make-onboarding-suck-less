# Tanzu Application Platform Evaluation

## Installation

* [TKG 1.4.0 on AWS](tkg/aws/INSTALL.md)
* [on AKS](aks/INSTALL.md)
* [on EKS](eks/INSTALL.md)
* [on GKE](gke/INSTALL.md)

## Usage

Congratulations! You've managed to install TAP.  Now what?

Well, the answer to that question is only going to be partially addressed here.  The `full` platform profile is comprised of a number of components collectively delivering capabilities designed to help you go from idea to deployment with alacrity.

We'll touch on how to interact with a handful of those components here:

// FIXME Links to public docs below need updates

* Cloud Native Runtimes
  * [Verifying your Cloud Native Runtimes installation](https://docs.vmware.com/en/Cloud-Native-Runtimes-for-VMware-Tanzu/1.0/tanzu-cloud-native-runtimes-1-0/GUID-verify-installation.html)
    * As you walk through Knative Serving, Knative Eventing, and TriggerMesh SAWS you won't need to create a cluster role binding as this has been taken care of by the package.
  * [Enabling Automatic TLS Certificate Provisioning for Cloud Native Runtimes for Tanzu](https://docs.vmware.com/en/Cloud-Native-Runtimes-for-VMware-Tanzu/1.0/tanzu-cloud-native-runtimes-1-0/GUID-auto-tls.html)
* Application Accelerator
  * Available within Tanzu Application Platform GUI.
  * [Using Application Accelerator for VMware Tanzu](https://docs.vmware.com/en/Application-Accelerator-for-VMware-Tanzu/0.4/acc-docs/GUID-installation-install.html#access-the-application-accelerator-ui-server-1)
  * [Accelerator Commands](https://docs.vmware.com/en/Application-Accelerator-for-VMware-Tanzu/0.4/acc-docs/GUID-acc-cli.html#accelerator-commands-2)
  * [Creating Accelerators](https://docs.vmware.com/en/Application-Accelerator-for-VMware-Tanzu/0.4/acc-docs/GUID-creating-accelerators-index.html)
* [Application Live View](https://docs.vmware.com/en/Application-Live-View-for-VMware-Tanzu/0.4/docs/GUID-index.html)
  * Available within Tanzu Application Platform GUI
  * [Product Features](https://docs.vmware.com/en/Application-Live-View-for-VMware-Tanzu/0.4/docs/GUID-product-features.html)
* Tanzu Application Platform GUI
  * Visit `https://tap-gui.{domain}` in your favorite browser.  Replace `{domain}` with your domain.
  * Public [documentation](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/0.4/tap-0-4/GUID-tap-gui-about.html)
* Learning Center
  * You can check the Training Portals available in your environment running the following command `kubectl get trainingportals`
  * Public [documentation](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/0.4/tap-0-4/GUID-learning-center-about.html)
* API Portal
  * Visit `https://api-portal.{domain}` in your favorite browser.  Replace `{domain}` with your domain.
  * [Viewing APIs](https://docs.pivotal.io/api-portal/1-0/api-viewer.html)

A tutorial on what capabilities a developer may leverage may be found [here](USAGE.md).  Also, to whet your appetite, please view the section below entitled [For your consideration](#for-your-consideration).


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
  * [Tanzu Application Platform - Scan and Store capability](https://www.youtube.com/watch?v=rJ3ySaIfc5M)
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
