#!/usr/bin/env bash

set -euo pipefail

path=$(cd $(dirname "${BASH_SOURCE:-$0}") && pwd)

#
# Setup clusters
#
echo -n "Kind cluster 001: "
kind get clusters | grep gitops-multi-001 || kind create cluster --name gitops-multi-001 --config=kind-multi-config-001.yaml

echo -n "Kind cluster 002: "
kind get clusters | grep gitops-multi-002 || kind create cluster --name gitops-multi-002 --config=kind-multi-config-002.yaml

#
# Setup gitops repositories
#
cp -r $path/resilience/clusters $path/hack
pushd $path/hack/clusters

if [ ! -d .git ]; then
    git init
fi

git add .
git commit -m "feat: Initial commit"

if [ ! -d $path/hack/git-server/repos/clusters.git ]; then
  git clone --bare $path/hack/clusters $path/hack/git-server/repos/clusters.git
  git remote add origin $path/hack/git-server/repos/clusters.git
  git pull --set-upstream origin main
else
  git push
fi
popd

cp -r $path/resilience/infrastructure $path/hack
pushd $path/hack/infrastructure

if [ ! -d .git ]; then
    git init -b innovators
fi

git add .
git commit -m "feat: Initial commit"

if [ ! -d $path/hack/git-server/repos/infrastructure.git ]; then
  git clone --bare $path/hack/infrastructure $path/hack/git-server/repos/infrastructure.git
  git remote add origin $path/hack/git-server/repos/infrastructure.git
  git pull --set-upstream origin innovators
else
  git push
fi

for zone in early-adopters early-majority late-majority laggards; do
  git branch $zone
  git push -u origin $zone:$zone
done

popd

#
# Bootstrap clusters
#
known_hosts="$(ssh-keyscan -p 2222 localhost 2>/dev/null | sed "s/localhost/host.docker.internal/g")"

# Bootstrap flux on cluster 001
if kubectl --context kind-gitops-multi-001 get -n flux-system deployments 2>&1 | grep -q "No resources found"; then
    flux install --context kind-gitops-multi-001 --namespace=flux-system
    kubectl --context kind-gitops-multi-001 create secret generic -n flux-system flux-system --from-file=identity=$path/hack/git-server/keys/sync-key --from-file=identity.pub=$path/hack/git-server/keys/sync-key.pub --from-literal=known_hosts="$known_hosts"
    kubectl --context kind-gitops-multi-001 apply -k $path/hack/clusters/cluster-001
fi

# Bootstrap flux on cluster 002
if kubectl --context kind-gitops-multi-002 get -n flux-system deployments 2>&1 | grep -q "No resources found"; then
    flux install --context kind-gitops-multi-002 --namespace=flux-system
    kubectl --context kind-gitops-multi-002 create secret generic -n flux-system flux-system --from-file=identity=$path/hack/git-server/keys/sync-key --from-file=identity.pub=$path/hack/git-server/keys/sync-key.pub --from-literal=known_hosts="$known_hosts"
    kubectl --context kind-gitops-multi-002 apply -k $path/hack/clusters/cluster-002
fi
