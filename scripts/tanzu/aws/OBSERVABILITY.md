# Observability, Metrics and Call Tracing for Microservices

Identify and target a workload cluster.

If your workload cluster is registered or attached with Tanzu Mission Cotnrol, then [integrate](https://docs.wavefront.com/integrations_tmc_howto.html) it with Tanzu Observability.


## (Optionally) Fetch the source

```
git clone https://github.com/pacphi/tut-metrics-and-tracing
```


## Publish images

For client

```
kp image save client \
  --git https://github.com/pacphi/tut-metrics-and-tracing \
  --git-revision TBD \
  --tag harbor.lab.zoolabs.me/apps/client \
  --registry-ca-cert-path /home/ubuntu/.local/share/mkcert/rootCA.crt \
  --wait
```

For server

```
kp image save server \
  --git https://github.com/pacphi/tut-metrics-and-tracing \
  --git-revision TBD \
  --tag harbor.lab.zoolabs.me/apps/server \
  --registry-ca-cert-path /home/ubuntu/.local/share/mkcert/rootCA.crt \
  --wait
```
