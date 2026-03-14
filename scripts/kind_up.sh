#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-manifests-starter}"

kind create cluster --name "${CLUSTER_NAME}" --wait 120s
