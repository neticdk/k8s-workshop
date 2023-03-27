# Install observability stack on kubernetes

In order to get started with this part of the workshop, please navigate to the `observability` folder

Create the cluster for this part of the workshop:

```console
$ ./create_cluster.sh
```

Install namespace
```console
$ kubectl create -f ./namespace.yaml
```
Get the installed namespaces
```console
$ kubectl get namespaces
```
List the contents of the previously installed namespace declaration
```console
$ cat namespace.yaml
```

## install operator

You may install everything in a folder using a declarative approach, here we install everything from the `setup` folder in one command
```console
$ kubectl create -f setup
```
Which installs a set of Custom Resource Defintitions or in short CRDs - if you want to see them, you can get the installed custom ressources by:
```console
$ kubectl get customresourcedefinition.apiextensions.k8s.io
$ kubenctl get customresourcedefinition.apiextensions.k8s.io/alertmanagers.monitoring.coreos.com -o yaml
````

And you may describe one of the custom ressources by: 
```console
$ kubectl describe customresourcedefinition.apiextensions.k8s.io/alertmanagers.monitoring.coreos.com
```

## install reminder
Now we have the CRDs installed and we are going to get the remaining components installed. These are e.g. prometheus (a metrics component), alertmanager (alerting component) and grafana (a visualizing tool).
We use the same principle as above using the install from a folder called `install`
```console
$ kubectl create -f install
```
Watch as the pods are created and gets ready, by looking for the pods and adding a `-w` which allows you to see as the pods get ready 
## check running pods
```console
$ kubectl get pods -n monitoring -w
```

At the time where all pods are running:
## check servises
```console
$ kubectl get svc -n monitoring
```
Note that there is a grafana service, a prometheus service and an alert manager service.

## access grafana 
```console
$ kubectl --namespace monitoring port-forward svc/grafana 3000
````

http://localhost:3000
Username: admin
Password: admin (which you have to change on first login please change to admin2)


## access prometheus
```console
$ kubectl --namespace monitoring port-forward svc/prometheus-k8s 9090
````

http://localhost:9090

## access alertmanager
```console
$ kubectl --namespace monitoring port-forward svc/alertmanager-main 9093
```
http://localhost:9093

## why no data
When you look at the various dashboards you see that there are no data in them.
This is done to a set of network policies that are installed by default into the cluster.
These are useful objects and have a very significant impact on security in real clusters, 
this is however just a workshop and thus we remove them instead of working with them.
If you are on windows, you may not experience the same results.

### check network policies
```console
$ kubectl get networkpolicies
```

### get rid of them now
```console
$ kubectl -n monitoring delete networkpolicies.networking.k8s.io --all
```

Now there is data in the daskboards.

![grafana](grafana.png)

![prometheus](prometheus.png)

![alertmanager](alertmanager.png)

[Read More](https://computingforgeeks.com/setup-prometheus-and-grafana-on-kubernetes/)

## Clean up
```console
$ ./delete_cluster.sh
```
