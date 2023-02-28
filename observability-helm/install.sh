#!/usr/bin/env bash

helm repo add netic-oaas https://neticdk.github.io/k8s-oaas-observability
helm upgrade -i oaas-observability netic-oaas/oaas-observability --set opentelemetry-operator.enabled=false --set vector-agent.enabled=false --set grafana.adminPassword=workshop
