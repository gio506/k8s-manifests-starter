# Files Explained

- `.github/workflows/manifest-ci.yaml`: 4-stage CI for YAML lint, schema validation, kustomize build, and dry-run checks.
- `.yamllint.yaml`: YAML linting rules for manifests and workflow files.
- `CHEATSHEET.md`: quick commands for kind, kubectl, and kustomize.
- `FILES_EXPLAINED.md`: short purpose statement for every tracked file.
- `README.md`: project guide with local run, validation, and cleanup notes.
- `k8s/base/*`: reusable Kubernetes base manifests.
- `k8s/overlays/dev/*`: development overlay with replica and environment changes.
- `k8s/kustomization.yaml`: top-level entrypoint pointing to the dev overlay.
- `scripts/kind_up.sh`: creates a local kind cluster.
- `scripts/smoke.sh`: applies a simple HTTP smoke check through port-forwarding.
