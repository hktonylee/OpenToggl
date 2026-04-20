# OpenToggl local Kubernetes deployment

This directory provides a local Kubernetes equivalent of the root `docker-compose.yml` stack:

- `postgres` (`postgres:17-alpine`) with persistent storage
- `redis` (`redis:8-alpine`) with password auth
- `opentoggl` (`ghcr.io/correctroadh/opentoggl:latest`)

## 1) Configure secrets

Update `secrets.yaml` values before deploy:

- `postgres-password`
- `redis-password`
- `database-url`
- `redis-url`

Keep passwords consistent between `*-password` and corresponding URL values.

## Service DNS names

Kubernetes Service DNS already resolves these names via CoreDNS (no manual CoreDNS entries needed):

- `postgres.opentoggl-local.svc.cluster.local`
- `redis.opentoggl-local.svc.cluster.local`
- `opentoggl.opentoggl-local.svc.cluster.local`

The default `database-url` and `redis-url` in `secrets.yaml` already use the fully qualified Service DNS names above.

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

This setup exposes OpenToggl as NodePort `30080`.

- Kind/minikube or single-node local clusters: `http://<node-ip>:30080`
- Or port-forward:

```bash
kubectl -n opentoggl-local port-forward svc/opentoggl 8080:8080
```

Then open `http://127.0.0.1:8080`.
