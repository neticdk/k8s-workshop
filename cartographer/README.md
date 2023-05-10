# Cartographer Example

- Consider running the registry inside of the cluster? It is merely to be able to push a container image.

For those interested I think I came with a simpler solution to route network to the host machine, using headless or ExternalName services. The solution is different for Linux and Mac/Window (the latter using Docker desktop).

Linux solution: headless service + endpoint:

```yaml
---
apiVersion: v1
kind: Endpoints
metadata:
  name: dockerhost
subsets:
- addresses:
  - ip: 172.17.0.1 # this is the gateway IP in the "bridge" docker network
---
apiVersion: v1
kind: Service
metadata:
  name: dockerhost
spec:
  clusterIP: None
```

Mac/Windows (Docker Desktop) solution: ExternalName service:

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: dockerhost
spec:
  type: ExternalName
  externalName: host.docker.internal
```
