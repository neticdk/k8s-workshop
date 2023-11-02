#!/usr/bin/env bash

path=$(cd $(dirname "${BASH_SOURCE:-$0}") && pwd)

kind delete cluster --name gitops-multi-001
kind delete cluster --name gitops-multi-002

rm -rf $path/hack/multicluster
rm -rf $path/hack/git-server/repos/multicluster.git
