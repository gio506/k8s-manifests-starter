# k8s-manifests-starter

Starter Kubernetes manifests for deploying a simple nginx web app with local **kind** instructions and CI checks.

## What is included

- Namespace
- ConfigMap
- Deployment
- Service
- Ingress (optional to use locally)
- HorizontalPodAutoscaler (optional; requires Metrics Server)
- Kustomize entrypoint (`k8s/kustomization.yaml`)

## Project tree

```text
.
├── .github/workflows/manifest-ci.yaml
├── .yamllint.yaml
├── CHEATSHEET.md
├── README.md
└── k8s
    ├── configmap.yaml
    ├── deployment.yaml
    ├── hpa.yaml
    ├── ingress.yaml
    ├── kustomization.yaml
    ├── namespace.yaml
    └── service.yaml
```

### File quick purpose

- `.github/workflows/manifest-ci.yaml`: CI pipeline with yamllint, kubeconform, kustomize rendering, and dry-run checks.
- `.yamllint.yaml`: yamllint configuration.
- `CHEATSHEET.md`: command reference for cluster, deploy, debug, and cleanup.
- `k8s/namespace.yaml`: logical namespace (`demo-web`) for all resources.
- `k8s/configmap.yaml`: static `index.html` served by nginx.
- `k8s/deployment.yaml`: nginx Deployment with probes/resources and ConfigMap mount.
- `k8s/service.yaml`: ClusterIP Service exposing port 80.
- `k8s/ingress.yaml`: optional Ingress rule (`web.local`) for ingress-nginx.
- `k8s/hpa.yaml`: optional autoscaling based on CPU utilization.
- `k8s/kustomization.yaml`: single render/apply entrypoint.

## Prerequisites

- Docker
- kind
- kubectl
- (Optional) ingress-nginx on kind
- (Optional) Metrics Server for HPA metrics

## Local setup with kind

### 1) Create a local cluster

```bash
kind create cluster --name manifests-starter
kubectl cluster-info --context kind-manifests-starter
```

### 2) (Optional) Install ingress-nginx for Ingress testing

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```

### 3) Deploy manifests

```bash
kubectl apply -k k8s
```

### 4) Verify resources

```bash
kubectl get ns demo-web
kubectl -n demo-web get deploy,po,svc,ingress,hpa
kubectl -n demo-web rollout status deployment/web
```

### 5) Test app access

Port-forward (works without ingress):

```bash
kubectl -n demo-web port-forward svc/web 8080:80
curl -s http://localhost:8080 | head
```

Ingress test (if ingress-nginx installed):

```bash
curl -H "Host: web.local" http://127.0.0.1/
```

> If `web.local` does not resolve in your environment, map it in `/etc/hosts` or call `127.0.0.1` with the host header as shown above.

### 6) Optional HPA behavior check

HPA needs the Kubernetes Metrics API (`metrics-server`).

```bash
kubectl -n demo-web get hpa
kubectl top pods -n demo-web
```

If metrics are unavailable, the HPA object still exists but will show unknown metrics.

### 7) Cleanup

```bash
kind delete cluster --name manifests-starter
```

## CI pipeline stages

1. **yamllint**: syntax/style checks for YAML.
2. **schema-validate**: `kubeconform` strict schema validation.
3. **kustomize-build**: render resources via `kubectl kustomize`.
4. **manifest-check**: cluster-independent checks against rendered output (required kinds + namespace assertions).
