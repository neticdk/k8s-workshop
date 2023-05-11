# Workshop with Kubernetes
Welcome to this workshop. 
The workshop is associated with a [slide deck](https://drive.google.com/file/d/1w76DgKCXDoJdcWEi1BVDIyMzPxA-j32k/view?usp=sharing).
Material used in the workshop is based on different examples from github, articles and kubernetes.io

## Agenda

- Introduction to Cloud Native - what it is and what it is not
  - What is Cloud Native and what is Cloud
  - Cloud deployment models (hybrid,  cross, multi)
  - Cloud Native deployment models 
     - Public Cloud, 
     - Private Cloud, 
     - someones datacenter(s), 
     - your own datacenters(), 
     - a set of servers, 
     - a server, 
     - a workstation, 
     - a device, 
     - a car
     - and more

- Introduction to me/us
  - `whoami` (who are we) and `which` (what are we doing and why)

- We see Cloud Native as the biggest unifier and abstraction seen so far
  - A little more info about what Cloud native is and is not
  - Why must you know about Cloud Native
    What does it mean for you and your career?
    The broadest and most practical and coolest abstraction sofar!
    Covering everything from:
     - embedded to,
     - your machine, to 
     - your data centers, to 
     - other data centers, 
     - private cloud and 
     - public cloud(s)

- Why do you want to work with Cloud Native

  First and foremost: You will be working with Cloud Native.

  Regardless of what you will be doing:
  - developer
  - designer 
  - relliability engineer 
  - data scientist
  - electronics engineeer
  There will be Cloud Native Technology in code close to you.

- Where can you learn more about Cloud Native
  - Aalborg Cloud Native Meetup Community (part of CNCF and next meeting 28th of March 2023)
  - Experiment with it yourself on your laptop
  - Work someplace where they work with Kubernetes and other Cloud Native technologies are used for real (and secure) applications
  - Come join us, join us on our mission to make Kubernetes and Cloud Native available in a secure and easy manner for real applications

## Prerequisites
These are the things that you would have to install on your machine to run the examples.

### Install a local package manager
Dependent on which operating system you use, the easiest way to install the workshop tooling is by using the package manager which is most suitable to your operating system, on windows that would typically be `choco`, on MacOs `brew` and on linux it could be `snap`, however it is up to you what you prefer. If you happen to have some of the tools installed already, you may want to write `upgrade` instead of ìnstall`in the commands below.

### Docker Desktop
As we will be working with a local Kubernetes installation based on Docker a Docker Desktop
distribution needs to be installed.

See [Install Docker Engine](https://docs.docker.com/engine/install/).

### Kubernetes CLI
The `kubectl` cli allows access to interact with the Kubernetes cluster. This can be installed
from package managers.

### Conventions
The `$`at the start of the command line is only there to illustrate that this is a command line command, the command you write is the not including the `$`. If you see commands like cat, they will only work on Mac, Linux, and in the windows linux subsystem, if you are on native windows you can try `type`, if you see curl

**brew**

```console
brew install kubernetes-cli
```

**choco**

```console
choco install kubernetes-cli
```

For other ways of installing `kubectl` in Windows see [Install and Set Up kubectl on Windows](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)

### Kubernetes in Docker (kind)

We will be running a local Kubernetes cluster based on the Kubernetes distribution called
[kind](https://kind.sigs.k8s.io) - which is short for Kubernetes in Docker. This can be
installed using most package managers.

**brew**

```
brew install kind
```

**choco**

```
choco install kind
```

**Other**

For other install options see [Quick Start](https://kind.sigs.k8s.io/docs/user/quick-start/)

### k9s

Oprinally the [k9s](https://k9scli.io/) utility can help browsing and managing the Kubernetes cluster
providing a layer on top of the standard `kubectl` cli.

**brew**

```
brew install k9s
```

**choco**

```
choco install k9s
```

### Helm

A few of the examples require the [Helm](https://helm.sh/) tool to install packages into the Kubernetes cluster.

**brew**

```
brew install helm
```

**choco**

```
choco install kubernetes-helm
```

In the same way install `curl`, `docker` and `git`if you do not have these installed already

Alternate [Installing Helm](https://helm.sh/docs/intro/install/)


You can check that you have the tools available running.

```console
docker version
git version
kind version
helm version
k9s version
curl version
```

This should inform you about the `docker` and `kind` versions, furthermore you may check if any clusters are already running.

Make sure you have started the installed `docker desktop`.

## Please remember the purpose of the workshop
Please remember this is created for you to learn basic suff about kubernetes and to have an environment set up on you local workstation or laptop.
When you work through the workshops, by all means copy and paste commands, to avoid being stuck in misspelled commands. 
Please do reflect over each thing you do and try to deduct, what you did and and what was the result. 

- Lets start with what you can do in this room today
  - Lets get you signed up for Cloud Native Aalborg (https://community.cncf.io/aalborg/ and `join`)
  - Lets make sure you know where you get a coffe and a chat about Cloud Native and Kubernetes
  - Experiment with it yourself on your laptop ifo Kubernetes (there are a number of distributions and also some for you laptop)
    - [kubernetes](./simple-kubernetes) - start with this one
    - [ingress](./simple-kubernetes-with-ingress) - then go on to this one
    - [observability](./observability)
    - [kubedoom](./kubedoom)
  
## If you are using windows on your laptop
There are some few thing that may work in a different way under windows.

You may want to copy the lines from the shell scripts under each folder instead using the scripts:
- create_cluster.sh which would be e.g. `kind create cluster --name workshop --config=kind-config.yaml`
- delete_cluster.sh which would be e.g. `kind delete cluster --name workshop`
when creating and deleting local clusters.

The gatering of metrics in the observability workshop may not work for you, as grafana does not pick up the metrics.

## If you experience an older kind kubernetes version
You can add to the config yaml file, under nodes:
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
  image: kindest/node:v1.25.3
```

## If you want to play more with Kubernetes
[Kubernetes Playground](https://Kubernetes.io/docs/tutorials/kubernetes-basics/)

There are some articles that you can follow if you want to do more:

- https://opensource.com/article/21/6/kube-doom

- https://kubernetes.io/blog/2020/01/22/kubeinvaders-gamified-chaos-engineering-tool-for-kubernetes/

- https://github.com/Jorricks/Whac-a-mole-kubernetes

- https://grafana.com/tutorials/k8s-monitoring-app/

- https://grafana.com/grafana/dashboards/315-kubernetes-cluster-monitoring-via-prometheus/

- https://github.com/kubernetes/examples

- https://www.containiq.com/post/kubernetes-projects-for-beginners

- https://www.weave.works/blog/deploying-an-application-on-kubernetes-from-a-to-z

- https://github.com/javajon/kubernetes-observability (gammel)

- https://github.com/evry-bergen/kubernetes-workshop/tree/master/labs/1-pods

- https://williamlam.com/2020/06/interesting-kubernetes-application-demos.html

- https://github.com/Jorricks/Whac-a-mole-kubernetes

- https://github.com/luxas/kubeadm-workshop
