#!/usr/bin/env bash

set -euxo pipefail

path=$(cd $(dirname "${BASH_SOURCE:-$0}") && pwd)

pushd $path/simple-git-server
docker build -t simple-git-server .
popd

mkdir -p $path/hack/git-server/keys
if [ ! -f "$path/hack/git-server/keys/sync-key" ]; then
  ssh-keygen -t ed25519 -C "support@netic.dk" -f $path/hack/git-server/keys/sync-key -N ""
fi

mkdir -p $path/hack/git-server/repos

docker run --name=simple-git-server --rm -d -p 2222:22 -v $path/hack/git-server:/git-server simple-git-server
