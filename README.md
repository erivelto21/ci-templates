# CI workflow templates

This repository is a template repo for reusable CI workflows and helper scripts.

The main workflows in this repo validate pull request commit messages, Go pull requests, and publish images.

## What to use

- `scripts/validate-commit-message.sh` for validating commit subjects, including Git-generated merge commits.
- `.github/workflows/validate-pull-request-commit-messages.yml` as a reusable workflow for commit validation.
- `.github/workflows/validate-pull-request-go.yml` as a reusable workflow for Go pull request validation.
- `.github/workflows/publish-image.yml` as a reusable workflow for publishing images.
- `examples/github-actions/publish-image.yml` as a consumer example that publishes on merges to `main`.

## Example

```yaml
name: Validate CI

on:
  pull_request:

jobs:
  commit-message:
    uses: erivelto21/ci-templates/.github/workflows/validate-pull-request-commit-messages.yml@main
    with:
      commit_range: ${{ github.event.pull_request.base.sha }}..${{ github.event.pull_request.head.sha }}

  go-validation:
    uses: erivelto21/ci-templates/.github/workflows/validate-pull-request-go.yml@main
```

## Image publishing

Use `.github/workflows/publish-image.yml` from a consumer repository to build and push the image with the commit SHA as the immutable tag.
