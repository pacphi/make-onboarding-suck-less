#!/bin/bash

# @see https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/0.3/tap-0-3/GUID-scc-default-supply-chains.html#out-of-the-box-supply-chain-with-testing-and-scanning-sourcetestscantourl-5

cat > ootb-scanning.yaml << EOF
apiVersion: scanning.apps.tanzu.vmware.com/v1alpha1
kind: ScanPolicy
metadata:
  name: scan-policy
spec:
  regoFile: |
    package policies

    default isCompliant = false

    # Accepted Values: "Critical", "High", "Medium", "Low", "Negligible", "UnknownSeverity"
    violatingSeverities := ["Critical","High","UnknownSeverity"]
    ignoreCVEs := []

    contains(array, elem) = true {
      array[_] = elem
    } else = false { true }

    isSafe(match) {
      fails := contains(violatingSeverities, match.Ratings.Rating[_].Severity)
      not fails
    }

    isSafe(match) {
      ignore := contains(ignoreCVEs, match.Id)
      ignore
    }

    isCompliant = isSafe(input.currentVulnerability)

---
apiVersion: scanning.apps.tanzu.vmware.com/v1alpha1
kind: ScanTemplate
metadata:
  name: blob-source-scan-template
spec:
  template:
    containers:
    - args:
      - -c
      - ./source/scan-source.sh /workspace/source scan.xml
      command:
      - /bin/bash
      image: registry.tanzu.vmware.com/supply-chain-security-tools/grype-templates-image@sha256:36d947257ffd5d962d09e61dc9083f5d0db57dbbde5f5d7c7cd91caa323a2c43
      imagePullPolicy: IfNotPresent
      name: scanner
      resources:
        limits:
          cpu: 1000m
        requests:
          cpu: 250m
          memory: 128Mi
      volumeMounts:
      - mountPath: /workspace
        name: workspace
        readOnly: false
    imagePullSecrets:
    - name: image-secret
    initContainers:
    - args:
      - -c
      - ./source/untar-gitrepository.sh $REPOSITORY /workspace
      command:
      - /bin/bash
      image: registry.tanzu.vmware.com/supply-chain-security-tools/grype-templates-image@sha256:36d947257ffd5d962d09e61dc9083f5d0db57dbbde5f5d7c7cd91caa323a2c43
      imagePullPolicy: IfNotPresent
      name: repo
      volumeMounts:
      - mountPath: /workspace
        name: workspace
        readOnly: false
    restartPolicy: Never
    volumes:
    - emptyDir: {}
      name: workspace

---
apiVersion: scanning.apps.tanzu.vmware.com/v1alpha1
kind: ScanTemplate
metadata:
  name: private-image-scan-template
spec:
  template:
    containers:
    - args:
      - -c
      - ./image/copy-docker-config.sh /secret-data && ./image/scan-image.sh /workspace
        scan.xml true
      command:
      - /bin/bash
      image: registry.tanzu.vmware.com/supply-chain-security-tools/grype-templates-image@sha256:36d947257ffd5d962d09e61dc9083f5d0db57dbbde5f5d7c7cd91caa323a2c43
      imagePullPolicy: IfNotPresent
      name: scanner
      resources:
        limits:
          cpu: 1000m
        requests:
          cpu: 250m
          memory: 128Mi
      volumeMounts:
      - mountPath: /.docker
        name: docker
        readOnly: false
      - mountPath: /workspace
        name: workspace
        readOnly: false
      - mountPath: /secret-data
        name: registry-cred
        readOnly: true
    imagePullSecrets:
    - name: image-secret
    restartPolicy: Never
    volumes:
    - emptyDir: {}
      name: docker
    - emptyDir: {}
      name: workspace
    - name: registry-cred
      secret:
        secretName: image-secret
EOF

kubectl apply -f ootb-scanning.yaml
