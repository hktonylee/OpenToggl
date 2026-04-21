# OpenToggl local Kubernetes deployment

This directory provides a local Kubernetes equivalent of the root `docker-compose.yml` stack:

- `postgres` (`postgres:17-alpine`) with persistent storage
- `redis` (`redis:8-alpine`) with password auth
- `opentoggl` (`ghcr.io/correctroadh/opentoggl:latest`)
- Tailscale Ingress for tailnet access to `opentoggl`

The Tailscale Ingress requires the Tailscale Kubernetes Operator to be
installed in the cluster with MagicDNS and HTTPS enabled for the tailnet.

## 1) Configure secrets

Update `secrets.yaml` values before deploy:

- `postgres-password`
- `redis-password`

The OpenToggl pod builds `DATABASE_URL` and `REDIS_URL` from Kubernetes
Service environment variables plus these passwords. This keeps the runtime
explicit while avoiding a startup dependency on cluster DNS for internal
Postgres and Redis service names.

## Makefile shortcuts

From repository root:

```bash
make k8s-build IMAGE=ghcr.io/correctroadh/opentoggl:local
make k8s-deploy IMAGE=ghcr.io/correctroadh/opentoggl:local
```

Useful helpers:

```bash
make k8s-rollout
make k8s-port-forward
make k8s-delete
```

## 2) Apply manifests

```bash
kubectl apply -k k8s/local
```

## 3) Wait for rollout

```bash
kubectl -n opentoggl-local rollout status deploy/postgres
kubectl -n opentoggl-local rollout status deploy/redis
kubectl -n opentoggl-local rollout status deploy/opentoggl
```

## 4) Access app

This setup exposes OpenToggl through Tailscale Ingress:

```bash
kubectl -n opentoggl-local get ingress opentoggl
```

Open the assigned HTTPS hostname from a device signed in to the same tailnet.
It is usually:

```text
https://opentoggl.<tailnet-name>.ts.net
```

Fallback access remains available through NodePort `30080`.

- Kind/minikube or single-node local clusters: `http://<node-ip>:30080`
- Or port-forward:

```bash
kubectl -n opentoggl-local port-forward svc/opentoggl 8080:8080
```

Then open `http://127.0.0.1:8080`.
