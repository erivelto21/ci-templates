# Pull request commit message validation

This repository is a template repo for reusable CI workflows and helper scripts. The workflow below is the one you can copy into personal repositories or use as a local template inside this repo.

Use `scripts/validate-commit-message.sh` to validate commit subject lines in CI.

By default, the accepted formats are:

```text
feat: commit message
fix: commit message
chore: commit message
```

The script validates the commit subject only, which is the first line of a commit message. The subject must not be empty and must have at most 72 characters.

## Inputs

| Input | Required | Default | Description |
| --- | --- | --- | --- |
| `COMMIT_RANGE` | No | Current `HEAD` commit | Git revision range to validate, such as `base..head`. |

## Local usage

```bash
scripts/validate-commit-message.sh --message "feat: add login"
scripts/validate-commit-message.sh --file .git/COMMIT_EDITMSG
scripts/validate-commit-message.sh --range "origin/main..HEAD"
```

## Import in another project

Copy `.github/workflows/validate-pull-request-commit-messages.yml` into your project:

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

## Direct script usage in GitHub Actions

If you prefer not to use the reusable workflow, download and run the script in your workflow:

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
