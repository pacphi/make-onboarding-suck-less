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
      ref: 5e132ce4fa0100e1a263a538d7a710aff3d1d076
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
