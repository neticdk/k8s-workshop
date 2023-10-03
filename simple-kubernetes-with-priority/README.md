# Starting working with kubernetes and ingress and prioritised workload

This just serves as an example of how to work with ingress on a local kubernetes as you may already have seen from the workshop in the `simple-kubernetes-with-ingress` folder.

Make sure your are in the right place in your file system, switch to the `simple-kubernetes-with-priority`folder

This workshop shows you how to work with prioritised workloads in kubernetes and make sure that your workloads.  
 
## Create the cluster
We will use a kind cluster in this excercise, because it is easy to construct on your local machine and very easy to tear down as well.
Kind builds on docker and thus you should have docker installed an running.

```console
$ kind create cluster --name priority --config=config.yaml
```

## Install ingress controller

A Kubernetes ingress controller is a reverse-proxy or layer 7 load balancer, that is capable of handling network traffic
from outside of the cluster and route it to the pods inside of the cluster. Kubernetes contains an ingress resource type
to specify ingress configuration, but no ingress controllers are installed by default, as they may be specific for the
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

## Install the priority classes
Create a few prirority classes, e.g. `highest`, `medium` and `low` or adobt those from the `priority-classes.yaml` file. 

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: the-priority
value: 0000070000
preemptionPolicy: "PreemptLowerPriority"
globalDefault: false
description: "This is the higest an example of a Priority Class value"
```

Assuming that the prioritisation classes are created in a `priority-classes.yaml` file, the installation is continued based on that assumption.

```console
$ kubectl create -f ./priority-classes.yaml
```

You can check the existence of the priority classes by:

```console
$ kubectl get priorityclasses
```

You should see something along the lines of:

```console
NAME                      VALUE        GLOBAL-DEFAULT   AGE
higest-priority           90000        false            7s
low-priority              24576        true             7s
medium-priority           80000        false            7s
system-cluster-critical   2000000000   false            100s
system-node-critical      2000001000   false            100s
```

Which shows you the PriorityClasses you just deployed as well as 2 additional `system-cluster-critical` and `system-node-critical` which is default with kubernetes.
You can see that the 2 above have a much higher priority as the ones you have deployed, they are important to kubernetes itself, and thus more important than the workload.
Or if they do not exist you workload would not be running anyway. 

Furthermore you can see that one of the ones you have crerated are default and that is the low one.

```console
$ kubectl get priorityclasses -o yaml | grep preemptionPolicy
```
All the PriorityClasses are `preemptive` which can be seen from the `preemptionPolicy: PreemptLowerPriority` lines. That means that pods from lower priority may be evicted if there is a need for the resources used by lower priority pods, by higher priority pods. Then these higher priority pods will get scheduled where lower priority pods ran before.


If you want tom see then in a prioritised way and use JQ for that(you have to install `jq`):
```console
$ brew install jq
```
And then you can get the ouitput from the priority classes and sort then i prioritised sequence:

```console
$ kubectl get priorityclasses -o json | jq '[ .items[] | { name: .metadata.name, priority: (.value|tonumber) }]  |  sort_by (.priority) | reverse' | jq -r ' .[] | .name +  " -  " + (.priority|tostring) '
```

Where you should see something along the lines of:
```console
system-node-critical -  2000001000
system-cluster-critical -  2000000000
higest-priority -  90000
medium-priority -  80000
low-priority -  24576
```

## Install the applications

Take a look at the applications, which are basically a set of deployments with 3 different priority and qoutas assigned. The replica size varies.
The deployments are in each their separate file, as we are going to use then individually going forward.
An application having a high priority assigned can be found in `deployment-high-prio`.

```console
$ cat deployment-high-prio.yaml 
```

You should see:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: hello-foo
    app.kubernetes.io/instance: hello-foo
  name: hello-foo-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app.kubernetes.io/name: hello-foo
      app.kubernetes.io/instance: hello-foo
  template:
    metadata:
      labels:
        app.kubernetes.io/name: hello-foo
        app.kubernetes.io/instance: hello-foo
    spec:
      priorityClassName: higest-priority
      containers:
        - name: hello-foo-app
          command:
            - /agnhost
            - netexec
            - --http-port=8080
          image: registry.k8s.io/e2e-test-images/agnhost:2.39
          ports:
            - name: http
              containerPort: 8080
              protocol: TCP
          resources: 
            limits: 
              cpu: 90m
              memory: 25Mi
            requests: 
              cpu: 80m
              memory: 25Mi
```

Note that there is a `priorityClassName` set to `higest-priority` 


```console
$ cat deployment-no-prio.yaml 
```

You should see:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: hello-foobar
    app.kubernetes.io/instance: hello-foobar
  name: hello-foobar-app
spec:
  replicas: 16
  selector:
    matchLabels:
      app.kubernetes.io/name: hello-foobar
      app.kubernetes.io/instance: hello-foobar
  template:
    metadata:
      labels:
        app.kubernetes.io/name: hello-foobar
        app.kubernetes.io/instance: hello-foobar
    spec:
      priorityClassName: low-priority
      containers:
        - command:
            - /agnhost
            - netexec
            - --http-port=8080
          image: registry.k8s.io/e2e-test-images/agnhost:2.39
          name: hello-foobar-app
          ports:
            - name: http
              containerPort: 8080
              protocol: TCP
          resources: 
            limits: 
              cpu: 505m
              memory: 25Mi
            requests: 
              cpu: 185m
              memory: 25Mi

```

Note that there is no `priorityClassName` set.

Progess to install the application with no priority:
```console
$ kubectl create -f ./deployment-no-prio.yaml
```

Check that the priorityClassName has default been set to `lowest-priority`

```console
$ kubectl get deployments/hello-foobar-app -o yaml | grep priorityClassName
```
and after that:

```console
      priorityClassName: low-priority
```

and after that you want to see where the pods are residing:

```console
kubectl get pods -o wide
```
They should be evenly distributed across nodes and therefore it is interesting to see the number of pods that can be contained (if room enough) on each node:

```console
$ kubectl get nodes -o json | jq '.items | .[].status.allocatable.pods' 
```
which in this case is 110 pods per node. 

You want to know the number of pods running in the cluster in total, which means you need to find that number across namespaces:

```console
$ kubectl get pods -A -o wide
```
Or if you have `jq` installed:

```console
$ kubectl get pods -A -o json | jq '.items | length 
```
And you see that approximate 13 additional pods are running in the cluster.

In order to find the threshold for your lowest priority application in your current configuration. 
You can scale the deploymentto a max by e.g. scaling the deployment to a large number in a 2 workernode setup anything over 110*2 should be sufficient.
However what you should expect is to see a much lower number of Pods being sheduled and allowing to run on the worker nodes.

```console
$ kubectl scale --replicas=225 deployment/hello-foobar-app
```

The number of pods running:
```console
$ kubectl get pods -A -o wide | grep -c Running
```

Once that number stabilises you have reached the maximum number of running pods.
There should still be Pemnding pods.

```console
$ kubectl get pods -A -o wide | grep -c Pending
```

There should be pods pending in order to keep a maximum of pods deployet on the cluster, however more than 1-2 per node in pending is probably enough.
We want to tailor the pods to being just above the thrreshold for the cluster.

```console
$ kubectl get deployments/hello-foobar-app
```

where you can see that e.g.

```console
NAME               READY    UP-TO-DATE   AVAILABLE   AGE
hello-foobar-app   86/225   225          86          2m8s
```

Lets just set it to 90 pods
```console
$ kubectl scale --replicas=90 deployment/hello-foobar-app
```

```console
$ kubectl get deployments/hello-foobar-app
```

```console
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
hello-foobar-app   86/90   90           86          2m51s
```


If we deploy pods with a higher priority and have preemptive enabled as we have, we should see some pods being evicted and others being scheduled.

```console
$ kubectl create -f ./deployment-medium-prio.yaml
```

```console
$ kubectl get deployments/hello-foobar-app
```

```console
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
hello-foobar-app   82/90   90           82          13m
```

Which indicates that some pods have been evicted:

```console
$ kubectl get deployments/hello-bar-app
```

```console
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
hello-bar-app   4/4     4            4           29s
```
Shows that the four pods from `hello-foobar-app` was evicted to have 4 pods from `hello-bar-app` scheduled prioritised and they are now running.
So what happens when we want to deploy the deployment with the default low priority?

```console
$ kubectl create -f ./deployment-low-prio.yaml
```
The deployment is created

```console
$ kubectl get deployments/hello-baz-app
```

```console
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
hello-baz-app   0/8     8            0           17s
```

We see that the deployment is ok, however none of the Pods are running - no room was found and because they have the same priority as the `no-priority` deployments they are not preempting those.
Lets do the same for the highest priority deployment.

```console
$ kubectl create -f ./deployment-high-prio.yaml
```

```console
$ kubectl get deployments/hello-foo-app
```

```console
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
hello-foo-app   2/2     2            2           18s
```

```console
$ kubectl get deployments
```

```console
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
hello-bar-app      4/4     4            4           112s
hello-baz-app      0/8     8            0           63s
hello-foo-app      2/2     2            2           30s
hello-foobar-app   82/90   90           82          15m
```

## Poddisruptionbudgets will affect the prioritisation.
We will now create a deployment with the high and medium priority and give each of them a poddisruptionbudget.

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: high-prio-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: hello-foo-pbb-app
```

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: medium-prio-pdb
spec:
  minAvailable: 3
  selector:
    matchLabels:
      app.kubernetes.io/name: hello-bar-pdb-app
```
We create these two podDisruptionBudgets:
```console
$ kubectl create -f ./poddisruptionbudgets.yaml 
```

And we will create the applications using them

```console
$ kubectl create -f ./deployment-high-prio-pdb.yaml 
```

```console
$ kubectl get deployments                           
```
```console
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
hello-bar-app       4/4     4            4           2m48s
hello-baz-app       0/8     8            0           119s
hello-foo-app       2/2     2            2           86s
hello-foo-pdb-app   4/4     4            4           7s
hello-foobar-app    80/90   90           80          15m
```

Lets scale that last deployment:

```console
$ kubectl scale --replicas=80 deployment/hello-foo-pdb-app
```

```console
$ kubectl get deployments
```

```console
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
hello-bar-app       4/4     4            4           4m
hello-baz-app       0/8     8            0           3m11s
hello-foo-app       2/2     2            2           2m38s
hello-foo-pdb-app   80/80   80           80          79s
hello-foobar-app    48/90   90           48          17m
```

```console
$ kubectl create -f ./deployment-medium-prio-pbd.yaml
```

```console
$ kubectl get deployments 
```
```console
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
hello-bar-app       4/4     4            4           4m24s
hello-bar-pdb-app   8/8     8            8           6s
hello-baz-app       0/8     8            0           3m35s
hello-foo-app       2/2     2            2           3m2s
hello-foo-pdb-app   80/80   80           80          103s
hello-foobar-app    42/90   90           42          17m
```

Lets scale the medium one with PodDisruptionBudgets
```console
$ kubectl scale --replicas=80 deployment/hello-bar-pdb-app
```

```console
$ kubectl get deployments 
```
```console
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
hello-bar-app       4/4     4            4           6m13s
hello-bar-pdb-app   70/80   80           70          115s
hello-baz-app       0/8     8            0           5m24s
hello-foo-app       2/2     2            2           4m51s
hello-foo-pdb-app   80/80   80           80          3m32s
hello-foobar-app    0/90    90           0           19m
```

If we scale scale all the deployments to 80 pods
```console
$ kubectl scale --replicas=80 deployment/hello-foo-pdb-app 
$ kubectl scale --replicas=80 deployment/hello-foo-app 
$ kubectl scale --replicas=80 deployment/hello-bar-app
$ kubectl scale --replicas=80 deployment/hello-baz-app 
$ kubectl scale --replicas=80 deployment/hello-foobar-app
```

```console
$ kubectl get deployments                                        
```
```console
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
hello-bar-app       6/80    80           6           8m48s
hello-bar-pdb-app   19/80   80           19          4m30s
hello-baz-app       0/80    80           0           7m59s
hello-foo-app       80/80   80           80          7m26s
hello-foo-pdb-app   80/80   80           80          6m7s
hello-foobar-app    0/80    80           0           21m
```

We see that the high priority pods are complete, however the lower priorities are only 6 of desired 80 and 19 of desired 80.
Lets turn the nob for high priority workloads to see how the prioritation works. we scale the higher priority pods to a larger number.

```console
$ kubectl scale --replicas=105 deployment/hello-foo-pdb-app
```

```console
$ kubectl get deployments
NAME                READY     UP-TO-DATE   AVAILABLE   AGE
hello-bar-app       3/80      80           3           23m
hello-bar-pdb-app   6/80      80           6           19m
hello-baz-app       0/80      80           0           22m
hello-foo-app       80/80     80           80          21m
hello-foo-pdb-app   105/105   105          105         20m
hello-foobar-app    0/80      80           0           36m
```

Lets find the point where we force kubernetes to make a decision.

```console
$ kubectl scale --replicas=108 deployment/hello-foo-pdb-app
deployment.apps/hello-foo-pdb-app scaled
$ kubectl get deployments
NAME                READY     UP-TO-DATE   AVAILABLE   AGE
hello-bar-app       3/80      80           3           25m
hello-bar-pdb-app   4/80      80           4           20m
hello-baz-app       0/80      80           0           24m
hello-foo-app       80/80     80           80          23m
hello-foo-pdb-app   108/108   108          108         22m
hello-foobar-app    0/80      80           0           38m
```
Still within the PodDisruptionBudget limit where minAvailable was set to 3 for `hello-bar-pdb-app`

```console
$ kubectl scale --replicas=110 deployment/hello-foo-pdb-app 
deployment.apps/hello-foo-pdb-app scaled
$ kubectl get deployments
NAME                READY     UP-TO-DATE   AVAILABLE   AGE
hello-bar-app       3/80      80           3           25m
hello-bar-pdb-app   3/80      80           3           21m
hello-baz-app       0/80      80           0           24m
hello-foo-app       80/80     80           80          24m
hello-foo-pdb-app   110/110   110          110         23m
hello-foobar-app    0/80      80           0           38m
```
Now we hit the PodDisruptionBudget limit where minAvailable was set to 3 for `hello-bar-pdb-app`.
Which means is we demand further scaling for higher priority pods, kubernetes can no longer keep this budget.


```console
$ kubectl scale --replicas=111 deployment/hello-foo-pdb-app
deployment.apps/hello-foo-pdb-app scaled
$ kubectl get deployments
NAME                READY     UP-TO-DATE   AVAILABLE   AGE
hello-bar-app       3/80      80           3           25m
hello-bar-pdb-app   2/80      80           2           21m
hello-baz-app       0/80      80           0           25m
hello-foo-app       80/80     80           80          24m
hello-foo-pdb-app   111/111   111          111         23m
hello-foobar-app    0/80      80           0           39m
```

Now we get to the point where this reduction causes the break of the PodDisruptionBudget limit where minAvailable was set to 3 for `hello-bar-pdb-app`.
This point is very interesting as this indicates that kubernetes selects the pods that would not rely on a minAvailable set of pods.
One might have expected that the `hello-bar-app` was chosen over the `hello-bar-pdb-app` and that would have ended the other way around.
One could have expected that `hello-bar-app ` was 2 at this point and `hello-bar-pdb-app` was 3.

```console
$ kubectl scale --replicas=112 deployment/hello-foo-pdb-app 
deployment.apps/hello-foo-pdb-app scaled
$ kubectl get deployments
NAME                READY     UP-TO-DATE   AVAILABLE   AGE
hello-bar-app       2/80      80           2           26m
hello-bar-pdb-app   2/80      80           2           21m
hello-baz-app       0/80      80           0           25m
hello-foo-app       80/80     80           80          24m
hello-foo-pdb-app   112/112   112          112         23m
hello-foobar-app    0/80      80           0           39m
```
Now we are below the point and we have brokenthe PodDisruptionBudget limit where minAvailable was set to 3 for `hello-bar-pdb-app`.
Kubernetes tries to keep both workloads running by balancing the number of pods between the pods having the same priority. 
One could have expected that `hello-bar-app ` was 1 at this point and `hello-bar-pdb-app` was 3.

```console
$ kubectl scale --replicas=114 deployment/hello-foo-pdb-app 
deployment.apps/hello-foo-pdb-app scaled
$ kubectl get deployments
NAME                READY     UP-TO-DATE   AVAILABLE   AGE
hello-bar-app       2/80      80           2           26m
hello-bar-pdb-app   1/80      80           1           22m
hello-baz-app       0/80      80           0           25m
hello-foo-app       80/80     80           80          25m
hello-foo-pdb-app   114/114   114          114         24m
hello-foobar-app    0/80      80           0           39m
```

Now we are well below the PodDisruptionBudget limit where minAvailable was set to 3 for `hello-bar-pdb-app`.
One could have expected that `hello-bar-app ` was 0? at this point and `hello-bar-pdb-app` was 3? - however how should kubernetes know, they have the same priority.

```console
$ kubectl scale --replicas=115 deployment/hello-foo-pdb-app
deployment.apps/hello-foo-pdb-app scaled
$ kubectl get deployments
NAME                READY     UP-TO-DATE   AVAILABLE   AGE
hello-bar-app       2/80      80           2           26m
hello-bar-pdb-app   0/80      80           0           22m
hello-baz-app       0/80      80           0           26m
hello-foo-app       80/80     80           80          25m
hello-foo-pdb-app   115/115   115          115         24m
hello-foobar-app    0/80      80           0           40m
```
Now we are well below the PodDisruptionBudget limit where minAvailable was set to 3 for `hello-bar-pdb-app`.

Below we continue to increrase the number of pods that is desired to get running until exhaustion.

Scale to 117

```console
$ kubectl scale --replicas=117 deployment/hello-foo-pdb-app
deployment.apps/hello-foo-pdb-app scaled
$ kubectl get deployments
NAME                READY     UP-TO-DATE   AVAILABLE   AGE
hello-bar-app       1/80      80           1           52m
hello-bar-pdb-app   0/80      80           0           47m
hello-baz-app       0/80      80           0           51m
hello-foo-app       80/80     80           80          50m
hello-foo-pdb-app   117/117   117          117         49m
hello-foobar-app    0/80      80           0           65m
```
Scale to 118

```console
$ kubectl scale --replicas=118 deployment/hello-foo-pdb-app
deployment.apps/hello-foo-pdb-app scaled
$ kubectl get deployments
NAME                READY     UP-TO-DATE   AVAILABLE   AGE
hello-bar-app       1/80      80           1           52m
hello-bar-pdb-app   0/80      80           0           48m
hello-baz-app       0/80      80           0           51m
hello-foo-app       80/80     80           80          51m
hello-foo-pdb-app   118/118   118          118         49m
hello-foobar-app    0/80      80           0           65m
```
Scale to 119

```console
$ kubectl scale --replicas=119 deployment/hello-foo-pdb-app
deployment.apps/hello-foo-pdb-app scaled
$ kubectl get deployments
NAME                READY     UP-TO-DATE   AVAILABLE   AGE
hello-bar-app       0/80      80           0           53m
hello-bar-pdb-app   0/80      80           0           49m
hello-baz-app       0/80      80           0           52m
hello-foo-app       80/80     80           80          52m
hello-foo-pdb-app   119/119   119          119         50m
hello-foobar-app    0/80      80           0           66m
```

Scale to 120

```console
$ kubectl scale --replicas=120 deployment/hello-foo-pdb-app
deployment.apps/hello-foo-pdb-app scaled
$ kubectl get deployments
NAME                READY     UP-TO-DATE   AVAILABLE   AGE
hello-bar-app       0/80      80           0           54m
hello-bar-pdb-app   0/80      80           0           50m
hello-baz-app       0/80      80           0           53m
hello-foo-app       80/80     80           80          53m
hello-foo-pdb-app   120/120   120          120         51m
hello-foobar-app    0/80      80           0           67m
```

Scale to 121

```console
$ kubectl scale --replicas=121 deployment/hello-foo-pdb-app
deployment.apps/hello-foo-pdb-app scaled
$ kubectl get deployments
NAME                READY     UP-TO-DATE   AVAILABLE   AGE
hello-bar-app       0/80      80           0           56m
hello-bar-pdb-app   0/80      80           0           51m
hello-baz-app       0/80      80           0           55m
hello-foo-app       80/80     80           80          54m
hello-foo-pdb-app   120/121   121          120         53m
hello-foobar-app    0/80      80           0           69
```

Now we have exhausted the ability for the cluster to run further pods. 

Looking at the results from above you can see how kubernetes priotises and what the edge cases seems to be. 

Scale the applications down:

```console
$ kubectl scale --replicas=12 deployment/hello-foo-pdb-app
$ kubectl scale --replicas=10 deployment/hello-foo-app
$ kubectl scale --replicas=8 deployment/hello-bar-app
$ kubectl scale --replicas=6 deployment/hello-bar-pdb-app

$ kubectl get deployments
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
hello-bar-app       8/8     8            8           92m
hello-bar-pdb-app   6/6     6            6           87m
hello-baz-app       44/80   80           44          91m
hello-foo-app       10/10   10           10          90m
hello-foo-pdb-app   12/12   12           12          89m
hello-foobar-app    22/80   80           22          105m
```

Now we see that the capasity of the cluster is balancing  back towards a more balanced setup.

## Install the services for the applications

Take a look at the services, which are in front of the applications.

```console
$ cat services.yaml
```

Then install the services.

```console
$ kubectl create -f ./services.yaml
```

## Install the ingress for the services
Take a look at the local ingress definition for the services, where you will find 3 definitions. Two of these for `foo` and `bar` and one to use in a while called `baz`.

```console
$ cat ingress.yaml 
```
Lets us install the ingress

```console
$ kubectl create -f ./ingress.yaml
```

## Accessing the Application
Now when you access the application it is possible to use the Ingress Controller and the Ingress to select between the two applications through the two services:

To get the `hello-bar` application
```console
$ curl localhost/hello-bar/hostname
```
which takes you through the `hello-ingress` ingress to the `hello-bar-service` service to the `hello-bar-app` pod.

To get the `hello-foo` application
```console
$ curl localhost/hello-foo/hostname
```
which takes you through the `hello-ingress` ingress to the `hello-foo-service` service to the `hello-foo-app` pod

To get the `hello-baz` application 
```console
$ curl localhost/hello-baz/hostname
```

which takes you through the `hello-ingress` ingress through the `hello-baz-service` service to the `hello-baz-app` pods. The
`hello-baz-app` deployment contains 4 replicas. Try calling the hello-baz application several times using:

```console
$ curl localhost/hello-baz/hostname
```

and see that it returns different names, which informs you that traffic is sent to different pods, i.e., the loadbalancing
in the `baz` service balances across the pods. 

This means you now have an application deployed across "nodes" and you receive traffic from "outside" the cluster and that traffic is balancede across "nodes" into one of the instances of the application.
You can see that by examininig the names of the pods responding and knowing how these are distributed across "nodes" in the cluster:

```console
$ kubectl get pods -o wide
```

Or if you want to see the baz app isolated:

```console
$ kubectl get pods -o wide | grep baz
````

## Virtual Hosting

The above examples exposes the applications on the same hostname `localhost` routing the traffic based on the path of the
http request (hello-foo, hello-bar, hello-baz). The same ingress controller can also distinguish requests based on the
requested hostname. There is an example of this in the `multiple-domains` folder - take a look at the ingress resource.

```console
$ cat multiple-domains/ingress.yaml
```

and apply the specification:

```console
$ kubectl apply -f ./multiple-domains/ingress.yaml
```

Now check the response when calling using different hostnames:

```console
$ curl foo-127-0-0-1.nip.io/hostname
$ curl foopdb-127-0-0-1.nip.io/hostname
$ curl bar-127-0-0-1.nip.io/hostname
$ curl barpdb-127-0-0-1.nip.io/hostname
$ curl baz-127-0-0-1.nip.io/hostname
$ curl foobar-127-0-0-1.nip.io/hostname
```

_Note_ the three domains (foo-127-0-0-1.nip.io, foo-127-0-0-1.nip.io, foo-127-0-0-1.nip.io) all resolve to `127.0.0.1` (i.e., localhost) but the ingress controller will route based on the http host header.


## Working with the kubernetes scheduler mechanisms and using qoutas
In the example above we have worked with requests and limits on containers and not used that same thing on the namespaces, which means that the functionality done by the scheduler has not been demonstrated sofar.
This can be done be creating namespaces and links these to qoutas. Lets see how that is done.

```yaml

apiVersion: v1
kind: ResourceQuota
metadata:
  name: fixed-ns-quota
  namespace: fixed-quota-ns
spec:
  hard:
    requests.cpu: 900m
    requests.memory: 3000M
    limits.cpu: 900m
    limits.memory: 3000M
```
Which states the size for :

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: fixed-quota-ns
```
This forces the workloads in that namespace to define both Requests and Limits for all Pods and the qouta for the accumulated set of pods needs to be below the total.  
It is however also possible to allow for burstable cpu for a given namespace:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: vario-ns-quota
  namespace: vario-quota-ns
spec:
  hard:
    requests.cpu: 550m
    requests.memory: 100M
    limits.memory: 3000M
```
which state the qouta for:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: vario-quota-ns
```

And then try to deploy as you did above and see how kubernetes handles overcommit within each namespace in a deterministic way and using that together with priority classes that is giving you the opportunity to control your workload's behaviour relative to what is deployed into the same cluster.



# Workshop Intentions
The intentions of this workshop was to convey som initial knowledge on working with kubernetes in a very simple way, the aim being to leave you with a bit of knowledge that will hopefully ignite your interest in kubernetes, as it is possible to work with it on your local machine. Furthermore the aim of this excecise is to demonstrate to you that it is possible to run prioritsed workloads in kubernetes in a fairly simple way and that, if you choose you may used a deterministic scheduling option alobg with that.

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





