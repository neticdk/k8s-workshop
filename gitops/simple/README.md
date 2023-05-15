# Simple GitOps Layout

Simple approach towards a gitops dierctory structure. One repository for one cluster.

```sh
flux bootstrap git --url=https://example.com/repository.git --password=<password> --path=.
```
