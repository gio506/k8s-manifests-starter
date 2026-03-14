#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-demo-web}"
SERVICE="${SERVICE:-web}"
LOCAL_PORT="${LOCAL_PORT:-8080}"

cleanup() {
  if [[ -n "${PF_PID:-}" ]]; then
    kill "${PF_PID}" >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT

kubectl -n "${NAMESPACE}" port-forward "svc/${SERVICE}" "${LOCAL_PORT}:80" >/tmp/k8s-manifests-starter-port-forward.log 2>&1 &
PF_PID=$!

for _ in {1..20}; do
  if curl -fsS "http://127.0.0.1:${LOCAL_PORT}" >/tmp/k8s-manifests-starter-response.txt; then
    break
  fi
  sleep 1
done

grep -q "Hello from Kubernetes manifests starter!" /tmp/k8s-manifests-starter-response.txt
cat /tmp/k8s-manifests-starter-response.txt
