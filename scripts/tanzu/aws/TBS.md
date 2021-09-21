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
      ref: 3a77c5f1149c85696ce804bbd8bd5ed78de9c706
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
