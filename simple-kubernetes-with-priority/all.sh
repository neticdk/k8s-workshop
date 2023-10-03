#!/usr/bin/env bash

echo "deploying ingress controller" 
kubectl create -f ./ingress-controller.yaml
kubectl wait pod -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx,app.kubernetes.io/component=controller --for condition=Ready  --timeout=45s

kubectl create -f ./priority-classes.yaml
kubectl create -f ./deployment-no-prio.yaml
kubectl create -f ./deployment-medium-prio.yaml
kubectl create -f ./deployment-low-prio.yaml
kubectl create -f ./deployment-high-prio.yaml

kubectl create -f ./poddisruptionbudgets.yaml
kubectl create -f ./deployment-high-prio-pdb.yaml
kubectl create -f ./deployment-medium-prio-pbd.yaml