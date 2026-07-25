# Go pull request validation

This repository is a template repo for reusable CI workflows and helper scripts. The workflow below is the one you can copy into a Go repository or use as a local template inside this repo.

Use `.github/workflows/validate-pull-request-go.yml` to validate Go pull requests in CI.

The workflow is organized as:

```text
format-check ─┐
lint          ├──> build ───> test
tidy          ┘              ├──> test-race
                             └──> test-cover
```

## What it checks

- `format-check` verifies `gofmt` and `goimports` without rewriting files.
- `lint` runs `golangci-lint`.
- `tidy` runs `go mod tidy`, `go mod verify`, and fails if `go.mod` or `go.sum` change.
- `build` compiles the Go application after validation passes.
- `test`, `test-race`, and `test-cover` run in parallel after build.

## Local usage

```bash
gofmt -l .
goimports -l .
go mod tidy
go mod verify
go build ./...
go test ./...
go test -race ./...
go test -cover ./...
```

## Import in another project

Call `.github/workflows/validate-pull-request-go.yml` as a reusable workflow from your project:

```yaml
name: Validate CI

on:
  pull_request:

jobs:
  format-check:
    uses: erivelto21/ci-templates/.github/workflows/validate-pull-request-go.yml@main

  lint:
    uses: erivelto21/ci-templates/.github/workflows/validate-pull-request-go.yml@main
```
