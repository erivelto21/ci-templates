# CI workflow templates

This repository is a template repo for reusable CI workflows and helper scripts.

The main workflow in this repo validates pull request commit messages.

## What to use

- `scripts/validate-commit-message.sh` for validating commit subjects.
- `.github/workflows/validate-pull-request-commit-messages.yml` for pull request validation.

## Example

```yaml
name: Validate pull request commit messages

on:
  pull_request:

jobs:
  commit-message:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Validate commit messages
        shell: bash
        run: |
          curl -fsSL https://raw.githubusercontent.com/erivelto21/ci-templates/main/scripts/validate-commit-message.sh -o validate-commit-message.sh
          chmod +x validate-commit-message.sh
          ./validate-commit-message.sh --range "${{ github.event.pull_request.base.sha }}..${{ github.event.pull_request.head.sha }}"
```
