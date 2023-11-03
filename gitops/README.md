# Showcases on gitops

This directory contains different example on how to utilize [gitops](https://www.weave.works/technologies/gitops/)
to configure and deploy on Kubernetes.

## Prerequisite

Since gitops is naturally dependent on git, a simple git server must be running. The directory includes a small
git server container image in `simple-git-server`. This can be started by running the `start-git.sh` script. Once
the git server is running the remaining gitops setups can be tested out.

## Simple gitops Setup

The most simple gitops example is running a single cluster and a single repository. Running the script `setup-simple.sh`
will create the following setup:

- Create a git repository for cluster reconciliation in `hack/simple` seeded with files from `simple` - the git repo is set up with
  the git server as "remote" so it is possible to do git add, commit and push to update the cluster
- Create a kind cluster based on the `kind-simple-config.yaml` configuration
- Bootstrap the cluster with [flux](https://fluxcd.io/)
- Setup reconciliation against the local git server

The cluster can be torn down running `teardown-simple.sh`.

## Multiple Cluster Setup

The next example shows how to run multiple clusters reconciling against the same git repository. Running the script
`setup-multi.sh` will do the following:

- Create a git repository for cluster reconciliation in `hack/multicluster` seeded with files from `multicluster`
- Create two kind clusters based on `kind-multi-config-001.yaml` and `kind-multi-config-002.yaml`
- Bootstrap both clusters with [flux](https://fluxcd.io/)
- Setup reconciliation for both clusters but with different paths (`clusters/cluster-001` and `clusters/cluster-002`)

The setup can be torn down running `teardown-multi.sh`

## Multiple Clusters and Multiple git Repositories

The last example shows how to run multiple cluster reconciling against a common infrastructure git repository as well
as a git repository containing cluster specific configurations. The repository for infrastructure contains multiple
branches to enable control over the promotion path. To start up the example run the scripts `setup-resilience.sh` - this
will setup the following.

- Create two git repositories `hack/clusters` and `hack/infrastructure` as well as setting up branches to constitute the promotion
  path for the `hack/infrastructure` repository.
- Create two kind clusters based on `kind-multi-config-001.yaml` and `kind-multi-config-002.yaml`
- Bootstrap both clusters with [flux](https://fluxcd.io/)
- Setup reconciliation for both clusters with a starting point in `clusters/cluster-001` and `clusters/cluster-002`
