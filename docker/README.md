## Docker image

If you want to build and run a portable container image, then execute

```
docker build -t tanzu/k8s-toolkit .
docker run --rm -it tanzu/k8s-toolkit /bin/bash
```