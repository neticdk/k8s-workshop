#!/usr/bin/env bash

path=$(cd $(dirname "${BASH_SOURCE:-$0}") && pwd)

kind delete cluster --name gitops-multi-001
kind delete cluster --name gitops-multi-002

rm -rf $path/hack/clusters
rm -rf $path/hack/infrastructure
rm -rf $path/hack/git-server/repos/clusters.git
rm -rf $path/hack/git-server/repos/infrastructure.git
