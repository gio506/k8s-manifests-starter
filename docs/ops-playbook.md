# Kubernetes Manifests — Ops Playbook

Operational procedures for managing applications deployed with these manifests.

---

## Scale Up / Down

```bash
# Scale the deployment to 5 replicas
kubectl scale deployment <app-name> --replicas=5

# Verify rollout completes
kubectl rollout status deployment/<app-name>

# Scale back down
kubectl scale deployment <app-name> --replicas=2
```

**When to scale up**: CPU usage > 70% sustained for 5 minutes, or p99 latency > 2× baseline.

---

## Rolling Restart (Zero-downtime)

```bash
# Trigger a rolling restart (e.g., to pick up new ConfigMap)
kubectl rollout restart deployment/<app-name>

# Monitor in progress
kubectl rollout status deployment/<app-name> --timeout=120s
```

---

## Rollback a Failed Deployment

```bash
# Immediately roll back to previous ReplicaSet
kubectl rollout undo deployment/<app-name>

# Roll back to a specific revision
kubectl rollout history deployment/<app-name>
kubectl rollout undo deployment/<app-name> --to-revision=3
```

---

## Debug a CrashLoopBackOff

```bash
# Step 1: Get the pod name
kubectl get pods -l app=<app-name>

# Step 2: Check events
kubectl describe pod <pod-name>

# Step 3: Get logs from the crashed container
kubectl logs <pod-name> --previous

# Step 4: If needed, override entrypoint to get a shell
kubectl run debug --image=<same-image> -it --rm -- /bin/sh
```

**Common causes**:
- Missing environment variable (check `envFrom` and `env` sections)
- Wrong image tag (check `describe pod` for image pull errors)
- Exceeded memory limit (check events for `OOMKilled`)
- App crashes in init (check init container logs separately)

---

## HPA Tuning

The HorizontalPodAutoscaler is configured in `k8s/hpa.yaml`:

```yaml
minReplicas: 2
maxReplicas: 10
metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

**Why 70% CPU target?** Leaves a 30% buffer for traffic spikes before scale-out triggers. Setting too low (50%) causes unnecessary expensive scale events. Too high (90%) means you're close to limits before more pods spin up.

```bash
# Check current HPA status
kubectl get hpa

# Watch real-time
kubectl get hpa --watch
```

---

## Namespace Cleanup

```bash
# List all resources in the namespace
kubectl get all -n <namespace>

# Delete a specific deployment
kubectl delete deployment <name> -n <namespace>

# Nuke everything in the namespace (use with extreme caution)
kubectl delete namespace <namespace>
```
