#!/usr/bin/env bash

echo "deploying ingress controller" 
kubectl create -f ./ingress-controller.yaml
kubectl wait pod -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx,app.kubernetes.io/component=controller --for condition=Ready  --timeout=45s

echo "deploying services" 
kubectl create -f ./services.yaml

echo "deploying applications"
kubectl create -f ./deployments.yaml
kubectl create -f ./ingress.yaml

echo "all set"
kubectl get all -A
