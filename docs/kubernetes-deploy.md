# Kubernetes deploy

This template provides a reusable workflow for deploying a published image to a Kubernetes cluster via Helm.

## What it does

- Checks out the infrastructure repository where the Helm chart lives.
- Sets up `kubectl` and `helm` on the runner.
- Configures the cluster kubeconfig from a single base64-encoded secret.
- Resolves the published image reference (same shared script as the publish workflow).
- Creates or updates the `imagePullSecret` for the private registry, idempotently.
- Runs `helm upgrade --install`, injecting `image.repository` and `image.tag`.
- Verifies the deployment rollout and fails early if it does not become ready.

## Prerequisites

The consumer must already publish the image with `publish-image.yml` so the
immutable `<registry>/<namespace>/<image>:<sha>` tag exists before deploy runs.

The Helm chart in the infrastructure repository MUST expose `image.repository`
and `image.tag` in its `values.yaml`, and SHOULD reference the `imagePullSecret`
(see `IMAGE_PULL_SECRET_NAME`) via `imagePullSecrets`.

## Inputs

| Input | Required | Default | Description |
| --- | --- | --- | --- |
| `chart_path` | Yes | - | Path to the Helm chart inside the infrastructure repository. |
| `release_name` | Yes | - | Helm release name. |
| `namespace` | Yes | - | Kubernetes namespace to deploy into. |
| `environment` | No | `production` | GitHub environment for approval gates and secret scoping. |
| `timeout` | No | `5m` | Helm upgrade and rollout timeout. |
| `values_file` | No | `""` | Optional path to a values file (e.g. a SOPS-encrypted secrets file) inside the infrastructure repository. When set, the workflow installs the `helm-secrets` plugin and runs `helm secrets upgrade` with `-f`. |

## Variables

| Variable | Required | Description |
| --- | --- | --- |
| `INFRA_REPO` | Yes | Infrastructure repository that holds the Helm chart. |
| `REGISTRY` | Yes | Registry host, such as `ghcr.io` or `registry.example.com`. |
| `REGISTRY_NAMESPACE` | No | Optional registry namespace or organization. |
| `IMAGE_NAME` | Yes | Image name without a tag. |
| `IMAGE_PULL_SECRET_NAME` | Yes | Name of the `imagePullSecret` to create/update in the namespace. |

## Secrets

| Secret | Required | Description |
| --- | --- | --- |
| `kubeconfig` | Yes | Base64-encoded kubeconfig for the target cluster. |
| `infra_token` | Yes | Token with read access to the infrastructure repository. |
| `registry_username` | Yes | Registry username or token owner. |
| `registry_password` | Yes | Registry password or access token. |
| `sops_age_key` | No* | Age private key used to decrypt SOPS-encrypted values files. *Required when `values_file` is set. |

## Example usage

```yaml
name: Deploy

on:
  push:
    branches:
      - main

jobs:
  publish:
    uses: erivelto21/ci-templates/.github/workflows/publish-image.yml@main
    with:
      build_context: .
    secrets: inherit

  deploy:
    needs: publish
    uses: erivelto21/ci-templates/.github/workflows/deploy-kubernetes.yml@main
    with:
      chart_path: charts/api
      release_name: api
      namespace: production
      values_file: charts/api/values.secret.yaml
    secrets: inherit
```

## Security notes

- Use a kubeconfig scoped to a ServiceAccount with the minimum permissions needed
  for the target namespace — never the cluster admin.
- Use a fine-grained token with read access limited to the infrastructure repository.
- Do not put application secrets in `values.yaml` or `--set`; the chart should
  reference secrets that already exist in the cluster.
- Keep registry and infrastructure values in repository variables and credentials
  in secrets, not in the workflow file.
