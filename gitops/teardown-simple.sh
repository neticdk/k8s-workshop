#!/usr/bin/env bash

path=$(cd $(dirname "${BASH_SOURCE:-$0}") && pwd)

kind delete cluster --name simple-gitops
rm -rf $path/hack/simple
rm -rf $path/hack/git-server/repos/simple.git
