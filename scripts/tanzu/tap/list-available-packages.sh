#!/bin/bash
set -e

namespace="tap-install"
available_packages=( "accelerator.apps.tanzu.vmware.com" "api-portal.tanzu.vmware.com" "appliveview.tanzu.vmware.com" "buildservice.tanzu.vmware.com" "cartographer.tanzu.vmware.com" "cnrs.tanzu.vmware.com" "controller.conventions.apps.tanzu.vmware.com" "controller.source.apps.tanzu.vmware.com" "developer-conventions.tanzu.vmware.com" "grype.scanning.apps.tanzu.vmware.com" "image-policy-webhook.signing.run.tanzu.vmware.com" "learningcenter.tanzu.vmware.com" "ootb-supply-chain-basic.tanzu.vmware.com" "ootb-supply-chain-testing-scanning.tanzu.vmware.com" "ootb-supply-chain-testing.tanzu.vmware.com" "ootb-templates.tanzu.vmware.com" "scanning.apps.tanzu.vmware.com" "scst-store.tanzu.vmware.com" "service-bindings.labs.vmware.com" "services-toolkit.tanzu.vmware.com" "spring-boot-conventions.tanzu.vmware.com" "tap-gui.tanzu.vmware.com" "tap.tanzu.vmware.com" "workshops.learningcenter.tanzu.vmware.com" )

for i in "${available_packages[@]}"
do
   tanzu package available list $i -n $namespace
done
