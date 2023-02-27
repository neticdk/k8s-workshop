# Starting working with kubernetes and ingress 

This just serves as an example of how to work with ingress on a local kubernetes
 
## Create the cluster
We will use a kind cluster in this excercise, because it is easy to construct on your local machine and very easy to tear down as well.
Kind build on docker and thus you should have docker installed an running.

```console
kind create cluster --name ingress --config=config.yaml
```

## Install ingress controller

A Kubernetes ingress controller is a reverse-proxy or layer 7 load balancer that is capable of handling network traffic
from outside of the cluster and route it to the pods inside of the cluster. Kubernetes contains an ingress resource type
to specify ingress configuration but no ingress controllers are installed by default, as they may be specific for the
infrastructures. Here we are running on a local machine and we will use nginx as ingress controller for this workshop example.

To see what is actually contained in the definition of an ingress controller and install it:

```console
$ cat ingress-controller.yaml 
$ kubectl create -f ./ingress-controller.yaml
```

Wait for deployment to be ready.

```console
$ kubectl wait pod -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx,app.kubernetes.io/component=controller --for condition=Ready  --timeout=45s
```

In the remaining parts of the workshop we will just use the default namespace for making it easier to write the commands you need to write.

## Install the applications

Take a look at the applications, which are basically two deployments with one replica (pod) each and one deployment
with 4 replicas.

```bash
$ cat deployments.yaml 
```

Progess to install these two application as:

```bash
$ kubectl create -f ./deployments.yaml
```

## Install the services for the applications

Take a look at the services, which are in front of the applications.

```bash
$ cat services.yaml 
```

Then install the services.

```bash
$ kubectl create -f ./services.yaml
```

## Install the ingress for the services
Take a look at the local ingress definition for the services, where you will find 3 definitions. Two of these for `foo` and `bar` and one to use in a while called `baz`.

```bash
$ cat ingress.yaml 
```
Lets us install the ingress

```bash
$ kubectl create -f ./ingress.yaml
```

## Accessing the Application
Now when you access the application it is possible to use the Ingress Controller and the Ingress to select between the two applications through the two services:

To get the `hello-bar` application
```bash
$ curl localhost/hello-bar/hostname
```
which takes you through the `hello-ingress` ingress to the `hello-bar-service` service to the `hello-bar-app` pod.

To get the `hello-foo` application
```bash
$ curl localhost/hello-foo/hostname
```
which takes you through the `hello-ingress` ingress to the `hello-foo-service` service to the `hello-foo-app` pod

To get the `hello-baz` application 
```bash
$ curl localhost/hello-baz/hostname
```

which takes you through the `hello-ingress` ingress through the `hello-baz-service` service to the `hello-baz-app` pods. The
`hello-baz-app` deployment contains 4 replicas. Try calling the application several times using:

```bash
$ curl localhost/hello-baz/hostname
```

and see that it returns different names, which informs you that traffic is sent to different pods, i.e., the loadbalancing
in the `baz` service balances across the pods.

# Workshop Intentions
The intentions of this workshop was to convey som initial knowledge on working with kubernetes in a very simple way, the aim being to leave you with a bit of knowledge that will hopefully ignite your interest in kubernetes, as it is possible to work with it on your local machine. 

Please tell us your feedback for us to be able to make a better job the next time, so please:
- what did you find hard in the workshop?
- what did you find tom easy in the workshop?
- how do you percieve that the workshop will help you starting to get aquinted with kubernetes going forward?
- did it ignite your interest for cloud native and kubernetes?
- what can we improve on the:
  - introductory part?
  - the practice part?
  - the notes and accompanying information?

# Thank you
If you wnat to know more about Cloud Native, Cloud Native Aalborg, Netic,kubernetes ot about the Secure Cloud Stack, please get in touch with us either in Netic, on Slack via Cloud Native Nordics or meet us in the Cloud Native Aalborg (or other cities) Meetups, or drop by for a cup of coffee (please write beforehand as we would like to be there on location).

## Peace





