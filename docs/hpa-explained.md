# HPA Explained — Horizontal Pod Autoscaler

Notes on the HPA configuration in this repo and why those values were chosen.

## What HPA Does

HPA monitors a metric (CPU, memory, or custom) and adjusts the number of running Pod replicas automatically:

```text
Target: 70% CPU
Current: 90% CPU (overloaded)
  → HPA adds pods until average CPU per pod ≈ 70%

Current: 20% CPU (underloaded)
  → HPA removes pods down to minReplicas=2
```

---

## Configuration Walkthrough

```yaml
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 2     # Never scale below this
  maxReplicas: 10    # Never scale above this
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### Why minReplicas: 2?

One replica = single point of failure. If the node running it is drained for maintenance, your app goes down for the pod startup time (~5–30s depending on image size). Two replicas guarantees ≥ 1 healthy pod during rolling updates.

### Why maxReplicas: 10?

Safety cap. Without it, a traffic storm (or a bug causing CPU-heavy loops) would spin up hundreds of pods, exhaust your node capacity, and crash the entire cluster. 10 is a reasonable upper bound for a lab.

### Why 70% CPU target?

Scale-out happens before the system is maxed out. At 90% threshold, users already experience degradation before new pods are up. At 70%, new pods start while there's still headroom.

---

## Checking HPA Status

```bash
# View current HPA state
kubectl get hpa -n <namespace>

# Full status with current/target metrics
kubectl describe hpa -n <namespace>

# Watch in real-time
kubectl get hpa --watch -n <namespace>
```

Expected output when healthy:
```
NAME     REFERENCE           TARGETS   MINPODS   MAXPODS   REPLICAS
my-app   Deployment/my-app   45%/70%   2         10        3
```

---

## When HPA Won't Scale

| Symptom | Likely Cause |
|---|---|
| `<unknown>/70%` target | Metrics server not installed (`kubectl apply -f metrics-server.yaml`) |
| Replicas stuck at min | CPU is actually low (app is efficient) — expected |
| Replicas won't go below min | `minReplicas` is the floor — this is correct |
| Scale-up not happening | Check metrics server is healthy: `kubectl top pods` |
