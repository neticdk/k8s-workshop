# Kubernetes Observabiltity Stack

To gain insights into the health of workloads in Kubernetes it is normal to install observability
tooling. Most observability stacks on Kubernetes is based on the work of
[Prometheus Monotoring Mixin for Kubernetes](https://github.com/kubernetes-monitoring/kubernetes-mixin).

Netic provides an open source distribution based on the standard Kubernetes Monitoring Mixin names [oaas-observability](https://github.com/neticdk/k8s-oaas-observability).

_Note_ this example requires the installation of the Helm package manager for Kubernetes.

## Install

Create cluster (`create_cluster.sh`):

```console
kind create cluster --name observability-helm --config=kind-config.yaml
```

Install the monitoring stack (`install.sh`):

```console
helm repo add netic-oaas https://neticdk.github.io/k8s-oaas-observability
helm upgrade -i oaas-observability netic-oaas/oaas-observability \
  --set opentelemetry-operator.enabled=false \
  --set vector-agent.enabled=false \
  --set grafana.adminPassword=workshop
```

## Access to Dashboards

It is not possible to access dashboards showing the data from the cluster through Grafana by
port-forwarding to the Grafana pod.

```console
kubectl port-forward svc/oaas-observability-grafana 3000:80
```

Go to http://localhost:3000 login is `admin` and password is `workshop`.


## What did we learn



## Clean up
```console
./delete_cluster.sh
```
