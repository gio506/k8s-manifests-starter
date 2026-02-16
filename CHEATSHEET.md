# Kubernetes Manifests Cheatsheet

This file explains **what each command is for** in this starter repo.

## Cluster lifecycle

- `kind create cluster --name manifests-starter`
  - Create a local Kubernetes cluster for testing manifests.
- `kind get clusters`
  - List local kind clusters.
- `kubectl cluster-info --context kind-manifests-starter`
  - Confirm API server connectivity.
- `kind delete cluster --name manifests-starter`
  - Remove the test cluster.

## Render and validate manifests

- `kubectl kustomize k8s`
  - Render all resources from `k8s/kustomization.yaml`.
- `kubectl kustomize k8s > rendered.yaml`
  - Save rendered resources to one file for validation/debugging.
- `kubectl apply --dry-run=client -f rendered.yaml`
  - Parse and validate manifests client-side without creating resources.
- `yamllint .`
  - Lint YAML style/formatting.
- `kubeconform -summary -strict k8s/*.yaml`
  - Validate resource schemas against Kubernetes OpenAPI specs.

## Deploy and inspect

- `kubectl apply -k k8s`
  - Deploy all manifests.
- `kubectl delete -k k8s`
  - Remove deployed resources.
- `kubectl get ns demo-web`
  - Check namespace creation.
- `kubectl -n demo-web get all`
  - List core workload resources.
- `kubectl -n demo-web get ingress,hpa`
  - Verify optional Ingress and HPA resources.
- `kubectl -n demo-web describe deployment web`
  - Inspect deployment details/events.
- `kubectl -n demo-web rollout status deployment/web`
  - Wait for deployment readiness.
- `kubectl -n demo-web logs deploy/web`
  - Read app logs from deployment pods.

## Access the app

- `kubectl -n demo-web port-forward svc/web 8080:80`
  - Expose service locally on port 8080.
- `curl -s http://localhost:8080`
  - Test web response via port-forward.
- `curl -H "Host: web.local" http://127.0.0.1/`
  - Test ingress route for host-based rule.

## Autoscaling checks (optional)

- `kubectl -n demo-web get hpa`
  - Show current autoscaler state.
- `kubectl top pods -n demo-web`
  - View pod CPU/memory usage (needs Metrics Server).
- `kubectl -n demo-web describe hpa web`
  - Inspect scaling targets and decisions.

## Useful troubleshooting

- `kubectl get events -A --sort-by=.metadata.creationTimestamp`
  - Cluster-wide recent events.
- `kubectl -n demo-web get pods -o wide`
  - Show pod IP/node placement.
- `kubectl -n demo-web exec -it deploy/web -- sh`
  - Open shell inside a running container.
