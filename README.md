# CI workflow templates

This repository is a template repo for reusable CI workflows and helper scripts.

The main workflows in this repo validate pull request commit messages, Go pull requests, React pull requests, and publish images.

## What to use

- `scripts/validate-commit-message.sh` for validating commit subjects, including Git-generated merge commits.
- `.github/workflows/validate-pull-request-commit-messages.yml` as a reusable workflow for commit validation.
- `.github/workflows/validate-pull-request-go.yml` as a reusable workflow for Go pull request validation.
- `.github/workflows/validate-pull-request-react.yml` as a reusable workflow for React pull request validation.
- `.github/workflows/publish-image.yml` as a reusable workflow for publishing images.
- `examples/github-actions/validate-pull-request-golang-ci.yml` as a consumer example that runs commit validation before Go validation.
- `examples/github-actions/validate-pull-request-react.yml` as a consumer example for React applications.
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

## React pull request validation

Use `.github/workflows/validate-pull-request-react.yml` from a consumer repository to validate React pull requests. Use `examples/github-actions/validate-pull-request-react.yml` when the repository should run commit validation before React validation.

The first version uses fixed npm commands:

| Command | Purpose |
| --- | --- |
| `npm install` | Install dependencies |
| `npm run build` | Build the application |
| `npx prettier --check .` | Verify formatting without rewriting files |
| `npm run lint` | Run ESLint or the project linter |
| `npm run type-check` | Run TypeScript type checking |
| `npm test -- --run` | Run tests once |
| `npm run test:coverage` | Run coverage tests |

React validation runs in this order:

```text
install
  -> build, format-check, lint, type-check, test, test-coverage
```

The final validation jobs run in parallel after `install` succeeds.

When using the composed React CI example, the order is:

```text
commit validation
  -> react validation
    -> install
      -> build, format-check, lint, type-check, test, test-coverage
```

## Image publishing

Use `.github/workflows/publish-image.yml` from a consumer repository to build and push the image with the commit SHA as the immutable tag.
