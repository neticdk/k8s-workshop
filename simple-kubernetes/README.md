# Start working with kubernetes

There are two fundamental ways to work with kubernetes:
 - the imperative way
 - the declarative way

where the declarative way seems to be the way most peoiple want to work with it in a real life scenario.

The following examples will show both ways of working. Lets see the differences on the two...

# Create the cluster

The main [README.md](../README.md) outllines the prerequisites to the examples. We will use [kind](https://kind.sigs.k8s.io/)
in this example, because it is easy to use to construct a Kubernetes cluster on your localn machine and very easy to
tear down as well.

You can check that you have the tools availeble running.

```console
$ docker version
$ kind version
```

This should tell you the `docker` and `kind` versions. Furthermore you may check if any clusters are already running.

```console
$ kind get clusters
```

Creating a new `kind` cluster simply run.

```console
$ kind create cluster
```

# Lets work with the impertive paradigm

## Deploy an Application
We deploy an application:

```bash
$ kubectl create deployment hello-app --image=registry.k8s.io/e2e-test-images/agnhost:2.39 -- /agnhost netexec --http-port=8080
```

We check that the application was created:

```bash
$ kubectl get deployments
```

The deployment is actually controlling container which exists inside a pod  

```bash
$ kubectl get pods
```

So what happened:

```bash
$ kubectl get events
```

To further explore what `kubecetl` can do for you
```bash
$ kubectl --help
```

## Connectivity to the Cluster

We havce used `kubectl` to retrieve information from the running cluster. It tursn out that
`kind` added entries into a default configuration for Kubernetes command line tooling such
that the tooling may connect to the cluster.

The `config` sub-commoand of `kubectl` can be used to view the configuration entries. The
configuration may contain a number of different contexts and the one we are currently using
can be found with:

```console
$ kubectl config current-context
```

Btw. what other contexts do we have?

```console
$ kubectl config get-contexts
```

Current context is normally in this workshop `kind`.

```console
$ kubectl config view | grep kind-workshop
```

## Expose the Application

An application which can not be used is not much fun is it?
Thus we will expose the application:

```bash
$ kubectl expose deployment hello-app --port=8080
```

Lets check what we got from the exposure:

```bash
$ kubectl get services
```

Lets try to make a connection directly to the service:

```bash
$ kubectl port-forward service/hello-app 30070:8080 
```

Find a browser and go to http://localhost:30070 And see the current time as the answer

If you have curl installed, you can achieve the same using:
```bash
$ curl http://localhost:30070
```

## What did we do

We used the command line to deploy an application and exposed that.
There was a lot done behind the scenes we did not look into, e.g., the deployment was done
into a particular "space" inside the cluster which is named `default`.

This can be seem is you make the following call:

```bash
$ kubectl get namespaces
```

You see one of these namespaces is called "default", and if we do not specify anything concerning namespaces
(and we did not) then everything which can go into a namesapce will go into that one.

We can use a short form for `namespaces` called `ns`
```bash
$ kubectl get ns
```

This will give us the same as above, we want to use that as a way to dive into the definion of a namespace:

```bash
$ kubectl get ns default -o yaml
```

which means we ask for the contents of the "namespace object" called "default" and requests to have the in the form of YAML.

The namespace object is one of the simplest objects in the kubernetes universe:
```yaml
apiVersion: v1
kind: Namespace
metadata:
  creationTimestamp: "2023-02-28T16:36:10Z"
  labels:
    kubernetes.io/metadata.name: default
  name: default
  resourceVersion: "192"
  uid: faeea1f1-aafd-4674-b894-5928c9543e83
spec:
  finalizers:
  - kubernetes
status:
  phase: Active
```

For the fun of it we could create another one:
```bash
$ kubectl create ns forthefunofit
$ kubectl get ns
```

You should now see that there is a namespace in the list called "forthefunofit":
```bash
$ kubectl get ns forthefunofit -o yaml
```

which means we ask for the contents of the "namespace object" called "forthefunofit" and requests to have the in the form of YAML

```yaml
apiVersion: v1
kind: Namespace
metadata:
  creationTimestamp: "2023-02-28T17:02:43Z"
  labels:
    kubernetes.io/metadata.name: forthefunofit
  name: forthefunofit
  resourceVersion: "3860"
  uid: 6721cc04-6748-45cc-a6bc-02d53152ef74
spec:
  finalizers:
    - kubernetes
status:
  phase: Active
```

There is nothing deployed into this namespace and thus it should be empty:

```bash
$ kubectl get all -n forthefunofit 
```

If we look back to the "default" namespace and does the same, we see that:

```bash
$ kubectl get all -n default 
```

or

```bash
$ kubectl get all
```

returns the same result.

For the sake of completeness we can take a look at the other objects we have worked with sofar:

```bash
$ kubectl get deployments hello-app  -o yaml
```

Or address the type and object in one single attribute:

```bash
$ kubectl get deployment.apps/hello-app  -o yaml
```

And do the same for the Service:

```bash
$ kubectl get service/hello-app/hello-app  -o yaml
```

Whereas when you to do that for pods you can do it as this:

```bash
$ kubectl get pods
```

And then ask for the object in YAML (remeber to substitute the name of the pod with what you see fron the output above):


```bash
$ kubectl get pod/hello-app-xx...xdbbc-yynl -o yaml
```

Or in a single command like this:

```bash
$ kubectl get pods $(kubectl get pods -template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}') -o yaml
```

If you remember the output from the Deployment object, you may recall that there was a line stating something about replicas:
```bash
$ kubectl get deployment.apps/hello-app -o jsonpath='{.spec.replicas}'
```

And that was default set to 1. This means that the application is supposed to have only one running pod. This can be seen by:
```bash
$ kubectl get pods
```

You can see one pod prefixed with `hello-app` and that 1 of 1 container is READY, let us try to look at the the actual object
handling the replicas for the deployment:

```bash
$  kubectl get rs
```

Looking at the output from abovve you can see that:
```console
NAME                   DESIRED   CURRENT   READY   AGE
hello-app-xxyyynnncd      1         1         1     7m
```

Which means that 1 instance is desired of the deployment pod, the current number is 1 and that one is ready.

And in order to follow that happening we can issue a command that sticks around and watches the changes e.g.:
```bash
$ kubectl get rs -w
```

Lets do the scaling from a different terminal window e.g. change the replica size to 4 and watch these numbers change:

```bash
$ kubectl scale --replicas=4 deployment/hello-app
```

Going back to the "sticking" view you should see:

```console
NAME                   DESIRED   CURRENT   READY   AGE
hello-app-xxyyynnncd   1         1         1       7m
hello-app-xxyyynnncd   4         1         1       8m
hello-app-xxyyynnncd   4         1         1       9m
hello-app-xxyyynnncd   4         4         1       9m
hello-app-xxyyynnncd   4         4         2       9m
hello-app-xxyyynnncd   4         4         3       9m
hello-app-xxyyynnncd   4         4         4       9m
```

If we check the deployment object again:

```bash
$ kubectl get deployment.apps/hello-app -o jsonpath='{.spec.replicas}'
```

You should see the number 4.

## Reconcillation Loop and desired state
Kubernetes attempts to maintain the desired state, which is what is defined for the cluster as the state it shouold be in.
As an example of that we just scaled the deployment to a replica size of 4, so what would happen is we deleted one of the replicas?

Lets look at the pods we have:

```bash
$ kubectl get pods 
```

Lets try to delete one of the pods:
```bash
$ kubectl delete pod hello-app-xxyyynnncd-kklkr1r 
```

You see that there are 4 pods running soon again, however the pod you just deleted is gone and replaced with a new one,
the result being that the desired state is obtained again.

```bash
$ kubectl get pods 
```

This is what sometimes is referred to as "self-healing", and that increases the robustness for keeping stuff running.

## Other useful commands and reference

Getting the logs from a given pod

```bash
$ kubectl logs pod/hello-app-xxyyynnncd-brre2nn
```

In the event that the pods has muliple running containers - you can specify the individuual container:

```bash
$ kubectl logs pod/hello-app-xxyyynnncd-brre2nn -c agnhost
```

Or if you want to have logs based on an assigned label:

```bash
$ kubectl logs -l app=hello-app 
```

There are plenty of commands that you can use for all sorts of things, please consult the
[kubectl cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

## What have we learned

You have seen how you can create, change and control objects in a kubernetes cluster using the command line and arguments
from the command line. We will now do the same in a declarative way, where the biggest difference is that you have you
configurations declared in files and kubectl is in this workshop used to push this information to the cluster.


So why is that important? - we will have a lok at that in the next section in the declarative section.

# The declarative way

The declarative way is, as mentioned earlier, when the objects used in kubernetes are specified (or declared) in files. In this section we 
will use kubectl to "push" these definitions to Kubernetes. As such this may not seem in this context to be a major gamechanger, however
in a real-life scenario this allows you to have the declarations separated from the commands that make the cluster aware of the
configurations it needs to deal with, and have them under version control. Having these declarations under version control gives you
the ability to treat configurations as source code and thus use the same paradigms for the infrastructure as for the code. This is among
other things full versioning, auditability, merge and conflict resolving, build and test of configurations. You can even use daemons
inside the cluster to fetch changes from the version control system and "pull" that into the cluster, thus avoiding distribution of
credentials with the ability to change things in the cluster instead protecting these inside the cluster. However this is a complete
topic on its own - for another day - perhaps.

In this workshop, we will work with the decalarative parts and just use kubectl to push the declarations to the cluster. We will be
using quite a lot of the same checking commands as you have already seen above. One big difference is that we are going to
deploy into a target namespace called "hello-workshop"

Lets start creating the namespace, but before that let us take a look at a very simple namespace definition:

```bash
$ cat namespace.yaml 
```

Which will look like this:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: hello-workshop
```

Let us create that in the cluster:

```bash
$ kubectl create -f ./namespace.yaml
```

Lets list the namespaces:
```bash
$ kubectl get ns
```

That may include the previously created namespace "forthefunofit" and then it would look like:

```console
NAME                 STATUS   AGE
default              Active   16m
forthefunofit        Active   12m
hello-workshop       Active   13s
kube-node-lease      Active   19m
kube-public          Active   19m
kube-system          Active   19m
local-path-storage   Active   19m
```

If we would delete the namespace we just created, that could be done like this
***do not delete it as we shall be using it later***:

```bash
$ kubectl delete -f ./namespace.yaml
```

If we want to do the same for the "forthefunofit" this can be done like:

```bash
$ kubectl delete ns forthefunofit
```

The resulting list would be:

```console
NAME                 STATUS   AGE
default              Active   16m
hello-workshop       Active   13s
kube-node-lease      Active   19m
kube-public          Active   19m
kube-system          Active   19m
local-path-storage   Active   19m
```

Now we can create the same deployment as before by applying the deployment from `deployment.yaml`. Note that
the namespace is already part of the specification in `deployment.yaml` and therefore the deployment ends up
in the `hello-workshop` namespace.

```bash
$ kubectl create -f ./deployment.yaml
```

Try to do overwrite the namespace by supplying to the command line, e.g.:

```bash
$ kubectl create -f ./deployment.yaml -n hello-workshop-non-existing-namespace
```

That will fail, however had it been a valid namespace it would have been deployed there as well.

Lets look at what has been deployed in the "hello-workshop" namespace.

```bash
$ kubectl get all -n hello-workshop
```

This looks very much like what we saw under the imperative paradigm for the "default" namespace above after deploying the `hello-app`.

```console
NAME                                  READY      STATUS       RESTARTS    AGE
pod/hello-app-57d9ccdbbc-vw2nn        1/1        Running      0           1m18s

NAME                                  READY      UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hello-app             1/1        1            1           1m18s

NAME                                   DESIRED   CURRENT      READY       AGE
replicaset.apps/hello-app-57d9ccdbbc   1         1            1           1m18s
```

So what did we deploy:

```bash
$ cat deployment.yaml
```
Which looks like this:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: hello-app
  name: hello-app
  namespace: hello-workshop
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-app
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: hello-app
    spec:
      containers:
      - command:
        - /agnhost
        - netexec
        - --http-port=8080
        image: registry.k8s.io/e2e-test-images/agnhost:2.39
        name: agnhost
```

If we do the same readback from the cluster as we did above under the imperative paradigm, we see:

```bash
$ kubectl get deployments.apps/hello-app -n hello-workshop -o yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
  creationTimestamp: "2023-02-28T17:32:22Z"
  generation: 1
  labels:
    app: hello-app
  name: hello-app
  namespace: hello-workshop
  resourceVersion: "15421"
  uid: afd4a6f4-5065-4851-ae2e-3f9a8ce90c87
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: hello-app
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: hello-app
    spec:
      containers:
      - command:
        - /agnhost
        - netexec
        - --http-port=8080
        image: registry.k8s.io/e2e-test-images/agnhost:2.39
        imagePullPolicy: IfNotPresent
        name: agnhost
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
status:
  availableReplicas: 1
  conditions:
  - lastTransitionTime: "2023-02-28T17:32:23Z"
    lastUpdateTime: "2023-02-22T17:32:23Z"
    message: Deployment has minimum availability.
    reason: MinimumReplicasAvailable
    status: "True"
    type: Available
  - lastTransitionTime: "2023-02-28T17:32:22Z"
    lastUpdateTime: "2023-02-28T17:32:23Z"
    message: ReplicaSet "hello-app-57d9ccdbbc" has successfully progressed.
    reason: NewReplicaSetAvailable
    status: "True"
    type: Progressing
  observedGeneration: 1
  readyReplicas: 1
  replicas: 1
  updatedReplicas: 1
```

So what happened here, the declared Deployment object was decorated with a lot of default settings and status information used
by kubernetes. The setting is something that you can specify yourself, however that would be an entire workshop, thus this is
not something we will cover in this workshop.

And what about the exposure we did above, how does that look as Declarative object?

```bash
$ cat service.yaml
```

Which looks like this:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-app
  namespace: hello-workshop
  labels:
    app: hello-app
spec:
  ports:
  - nodePort:
    port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    app: hello-app
  type: ClusterIP
```

Let us create that(we leave the namespace on the command line out as it is specified in the declaration):

```bash
$ kubectl create -f ./service.yaml
```

We check that a service has actually been created in the "hello-workshop" namespace.

```bash
$ kubectl get svc -n hello-workshop
```

And we take a closer look at it:

```bash
$ kubectl get svc hello-app -n hello-workshop -o yaml
```

```yaml
    apiVersion: v1
    kind: Service
    metadata:
    creationTimestamp: "2023-02-28T17:57:46Z"
    labels:
        app: hello-app
    name: hello-app
    namespace: default
    resourceVersion: "2352"
    uid: 593f5bad-7013-4485-8deb-1d97f5645b35
    spec:
    allocateLoadBalancerNodePorts: true
    clusterIP: 10.96.142.82
    clusterIPs:
    - 10.96.142.82
    externalTrafficPolicy: Cluster
    internalTrafficPolicy: Cluster
    ipFamilies:
    - IPv4
    ipFamilyPolicy: SingleStack
    ports:
    - nodePort: 30099
        port: 8080
        protocol: TCP
        targetPort: 8080
    selector:
        app: hello-app
    sessionAffinity: None
    type: LoadBalancer
    status:
    loadBalancer: {}
```

Again here we see the declared service object was decorated with a lot of default settings information used by kubernetes.

So what about scaling:

You change the number of replica in the deployment yaml file as:

```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
    labels:
        app: hello-app
    name: hello-app
    namespace: hello-workshop
    spec:
    replicas: 4
    selector:
        matchLabels:
        app: hello-app
    template:
        metadata:
        creationTimestamp: null
        labels:
            app: hello-app
        spec:
        containers:
        - command:
            - /agnhost
            - netexec
            - --http-port=8080
            image: registry.k8s.io/e2e-test-images/agnhost:2.39
        name: agnhost
```

And then you apply that change to the cluster by using a kubectl apply:

```bash
$ kubectl apply -f./deployment.yaml
```

And issue a:

```bash
$ kubectl get all -n hello-workshop
```

Which should tell you that there are four instances of hello-app running, in case you were wondering what you saw on the command line about "kubectl.kubernetes.io/last-applied-configuration" or in its entirety:

```console
Warning: resource deployments/hello-app is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"apps/v1","kind":"Deployment","metadata":{"annotations":{},"labels":{"app":"hello-app"},"name":"hello-app","namespace":"hello-workshop"},"spec":{"replicas":4,"selector":{"matchLabels":{"app":"hello-app"}},"template":{"metadata":{"creationTimestamp":null,"labels":{"app":"hello-app"}},"spec":{"containers":[{"command":["/agnhost","netexec","--http-port=8080"],"image":"registry.k8s.io/e2e-test-images/agnhost:2.39","name":"agnhost"}]}}}}
  creationTimestamp: "2023-02-28T18:32:22Z"
  generation: 2
  labels:
    app: hello-app
  name: hello-app
  namespace: hello-workshop
  resourceVersion: "18358"
  uid: afd4a6f4-5065-4851-ae2e-3f9a8ce90c87
spec:
  progressDeadlineSeconds: 600
  replicas: 4
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: hello-app
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: hello-app
    spec:
      containers:
      - command:
        - /agnhost
        - netexec
        - --http-port=8080
        image: registry.k8s.io/e2e-test-images/agnhost:2.39
        imagePullPolicy: IfNotPresent
        name: agnhost
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
status:
  availableReplicas: 4
  conditions:
  - lastTransitionTime: "2023-02-28T18:32:22Z"
    lastUpdateTime: "2023-02-28T18:32:23Z"
    message: ReplicaSet "hello-app-57d9ccdbbc" has successfully progressed.
    reason: NewReplicaSetAvailable
    status: "True"
    type: Progressing
  - lastTransitionTime: "2023-02-22T13:06:43Z"
    lastUpdateTime: "2023-02-22T13:06:43Z"
    message: Deployment has minimum availability.
    reason: MinimumReplicasAvailable
    status: "True"
    type: Available
  observedGeneration: 2
  readyReplicas: 4
  replicas: 4
  updatedReplicas: 4
```

If you want to scale it further, eg. to 8 change the deployment.yaml file replica size to e.g. 8


```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
    labels:
        app: hello-app
    name: hello-app
    namespace: hello-workshop
    spec:
    replicas: 8
    selector:
        matchLabels:
        app: hello-app
    template:
        metadata:
        creationTimestamp: null
        labels:
            app: hello-app
        spec:
        containers:
        - command:
            - /agnhost
            - netexec
            - --http-port=8080
            image: registry.k8s.io/e2e-test-images/agnhost:2.39
            name: agnhost
```
Control that the number of instances match the number of replicas:

```bash
$ kubectl get deployments.apps/hello-app -n hello-workshop
```

## What did we learn
You have seen how you can create, change and control objects in a Kubernetes cluster using a declarative approach, however still using
command line to tell the cluster about the things it need to work with. This approach opens up for what is refered to as pull based
GitOps, where all the good things from git can be brought into play such as full audit a merge and tag based approach to configuration
and control over your clusters.

# Lets zoom out for a bit

Kubernetes consist of a number of building blocks, they are depicted in the sketch below from kubernetes.io

![kubernetes building blocks](./img/components-of-kubernetes.svg)
The image is from [kubernetes.io, e.g.](https://kubernetes.io/docs/concepts/overview/components/)

The image shows a control-plane and 3 worker nodes, in our case we have a single control-plane and 2 worker nodes, which you may see
if you execute:

```bash
$ kubectl get nodes
```

In a setup like this for a workshop 1 control-plane node and 2 worker nodes are more than enough, in a real production setup you would
have 3, 5 or even 7 control-plane nodes and typically 3,6 or more by the factor of 3 nodes in a 3 Availability Zone setup, whereas in a
dual setup you would go for 4 or more by a factor of 2. 

If you want to have a view over "everything" thaht is running in the cluster you can do som by:

```bash
$ kubectl get all -A
```

This will show you the stuff like:
- etcd (etcd in the image) the state datastore which can exist across 1,3,5 or even 7 nodes, most commonly this is 1 for experiments and workshops, whereas the most common number is 3 for production workloads.
- apiserver (api in the image) the entry point where e.g. you just used the kubectl command line to communicate with in order to work with the kubernetes objects.
- controller-manager (cm in the image) this controls e.g Node, Job, 
  `Node controller` is Responsible for noticing and responding when nodes go down.
  `Job controller`is Watching for Job objects that represent one-off tasks, then creates Pods to run those tasks to completion.
  `EndpointSlice controller`populates EndpointSlice objects (to provide a link between Services and Pods), this is necessary for the knowledge of the  number fo pods "behind" the service.
- kube-proxy proxies (k-proxy in the image) is a network proxy that runs on each node in your cluster, thus you see one for every node in the list.
- kube-scheduler (sched in the image) lives in the control-plane and watches for newly created Pods with no assigned node, and make sure that a node is selected for them to run on


![nodes](./img/nodes.svg)

![pods](./img/pods.svg)

The images are from [kubernetes.io, e.g.]https://kubernetes.io/docs/tutorials/kubernetes-basics/explore/explore-intro/)


So which pod is running on which node:

```console
$ kubectl get pods -o wide
```

Which lists the pods include some extra information.

```console
NAME                         READY   STATUS    RESTARTS   AGE   IP            NODE                 NOMINATED NODE   READINESS GATES
hello-app-57d9ccdbbc-fjw48   1/1     Running   0          4s    10.244.0.13   kind-control-plane   <none>           <none>
hello-app-57d9ccdbbc-fq7xr   1/1     Running   0          12m   10.244.0.5    kind-control-plane   <none>           <none>
hello-app-57d9ccdbbc-tfcd7   1/1     Running   0          4s    10.244.0.15   kind-control-plane   <none>           <none>
hello-app-57d9ccdbbc-w9ql7   1/1     Running   0          4s    10.244.0.14   kind-control-plane   <none>           <none>
```

You can do the same for the "default" namespace (where you had 4 replicas):

```bash
$ kubectl get pods -owide
```

Earlier on we used a `port-forward` to send network traffic into the cluster. Even if we targetted a service resource the
`port-forward` work by setting up a tunnel to a specific pod. Thus no load balancing will happen. A more production like
Kubernetes setup needs an ingress setup and there is another workshop example covering [Kubernetes with ingress](../simple-kubernetes-with-ingress/README.md).

# Workshop Intentions

The intentions of this workshop was to convey som initial knowledge on working with kubernetes in a very simple way, the aim being to
leave you with a bit of knowledge that will hopefully ignite your interest in kubernetes, as it is possible to work with it on your
local machine. 

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
