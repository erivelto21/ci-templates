# Image publish

This template provides a reusable workflow for publishing an image after a merge lands on `main`.

## What it does

- Logs in to the target container registry.
- Builds the image from the configured Dockerfile and build context.
- Pushes the image with the current commit SHA as the only tag.

## Inputs

| Input | Required | Default | Description |
| --- | --- | --- | --- |
| `registry` | Yes | - | Registry host, such as `ghcr.io` or `registry.example.com`. |
| `namespace` | No | `""` | Optional registry namespace or organization. |
| `image_name` | Yes | - | Image name without a tag. |
| `build_context` | No | `.` | Docker build context. |

## Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `DOCKERFILE_PATH` | Yes | - | Path to the Dockerfile inside this CI templates repository. |

## Secrets

| Secret | Required | Description |
| --- | --- | --- |
| `registry_username` | Yes | Registry username or token owner. |
| `registry_password` | Yes | Registry password or access token. |

## Example usage

```yaml
name: Publish image

on:
  push:
    branches:
      - main

jobs:
  publish-image:
    uses: erivelto21/ci-templates/.github/workflows/publish-image.yml@main
    with:
      registry: ${{ vars.REGISTRY }}
      namespace: ${{ vars.REGISTRY_NAMESPACE }}
      image_name: read-tracker
      build_context: .
    secrets:
      registry_username: ${{ secrets.REGISTRY_USERNAME }}
      registry_password: ${{ secrets.REGISTRY_PASSWORD }}
```

## Output

The workflow pushes a single immutable image tag based on the commit SHA:

```text
<registry>/<namespace>/<image_name>:<commit-sha>
```

If `namespace` is empty, the image is pushed as:

```text
<registry>/<image_name>:<commit-sha>
```

## Security notes

- Use a registry credential with the minimum required push permissions.
- Do not rely on mutable tags for release identity.
- Keep registry values and credentials in repository variables and secrets, not in the workflow file.
