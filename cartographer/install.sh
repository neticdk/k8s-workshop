#!/usr/bin/env bash

flux -n netic-gitops-system install

kubectl apply -f ./deploy/cert-manager.yaml
kubectl wait helmrelease -n netic-security-system cert-manager --for condition=Ready

kubectl apply -k ./deploy
kubectl wait deployment -n cartographer-system cartographer-controller --for condition=Available=True
kubectl wait deployment -n kpack kpack-controller --for condition=Available=True
kubectl wait deployment -n kpack kpack-webhook --for condition=Available=True
kubectl wait deployment -n tekton-pipelines tekton-pipelines-controller --for condition=Available=True
kubectl wait deployment -n tekton-pipelines tekton-pipelines-webhook --for condition=Available=True
