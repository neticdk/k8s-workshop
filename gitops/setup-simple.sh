#!/usr/bin/env bash

path=$(cd $(dirname "${BASH_SOURCE:-$0}") && pwd)

# Create kind cluster - if not exists
echo -n "Kind cluster: "
kind get clusters | grep simple-gitops || kind create cluster --name simple-gitops --config=kind-simple-config.yaml

# Create gitops repo
cp -r $path/simple $path/hack/

pushd $path/hack/simple

if [ ! -d .git ]; then
    git init
fi

git add .
git commit -m "feat: Initial commit"

# Create reposiotory in server - if necessary
if [ ! -d $path/hack/git-server/repos/simple.git ]; then
  git clone --bare $path/hack/simple $path/hack/git-server/repos/simple.git
  git remote add origin $path/hack/git-server/repos/simple.git
else
  git push
fi

popd

# Bootstrap flux
if kubectl get -n flux-system deployments 2>&1 | grep -q "No resources found"; then
    echo Bootstrap flux
    kubectl create secret generic sync-key-secret --from-file=ssh-privatekey=$path/hack/git-server/keys/sync-key --from-file=ssh-publickey=$path/hack/git-server/keys/sync-key.pub
    kubectl apply -f $path/flux-bootstrap-job.yaml
    kubectl wait --for=condition=complete job/flux-bootstrap --timeout=120s
    kubectl delete -f $path/flux-bootstrap-job.yaml
    kubectl delete secret sync-key-secret
fi

# Sync changes from Flux back to git "workspace"
pushd $path/hack/simple
git pull --set-upstream origin main
popd
