#!/usr/bin/env bash

set -euo pipefail

path=$(cd $(dirname "${BASH_SOURCE:-$0}") && pwd)

kubectl apply -k ./supply-chain

known_hosts="$(ssh-keyscan -p 2222 localhost 2>/dev/null | sed "s/localhost/host.docker.internal/g")"
kubectl create secret generic -n cartographer-build git-auth --from-file=identity=$path/hack/git-server/keys/sync-key --from-file=identity.pub=$path/hack/git-server/keys/sync-key.pub --from-literal=known_hosts="$known_hosts"
kubectl create secret generic -n cartographer-build git-clone-auth --from-file=id_ed25519=$path/hack/git-server/keys/sync-key --from-literal=known_hosts="$known_hosts"

# Create git repo
cp -r $path/cartographer-demo $path/hack/

pushd $path/hack/cartographer-demo

if [ ! -d .git ]; then
    git init
fi

git add .
git commit -m "feat: Initial commit"

# Create reposiotory in server - if necessary
if [ ! -d $path/hack/git-server/repos/cartographer-demo.git ]; then
  git clone --bare $path/hack/cartographer-demo $path/hack/git-server/repos/cartographer-demo.git
  git remote add origin $path/hack/git-server/repos/cartographer-demo.git
else
  git push
fi

popd
