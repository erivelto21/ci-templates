## Why

Go pull request validation needs to be fast, predictable, and easy to reuse across repositories. Right now the validation shape is implicit, and format verification needs to be separated from formatting so CI can fail without rewriting files.

## What Changes

- Add a reusable Go pull request workflow template.
- Run format verification, lint, and dependency tidy in parallel.
- Run build only after the initial validation jobs succeed.
- Run test, test-race, and test-cover in parallel after build.
- Require non-mutating format verification in CI instead of applying formatting.

## Capabilities

### New Capabilities
- `go-pr-workflow`: reusable pull request validation for Go applications, including format verification, linting, dependency tidy, build, and test execution.

### Modified Capabilities
- None.

## Impact

Adds a new workflow template and supporting documentation for Go repositories. No application runtime code changes are required, but consuming repositories may need a non-mutating format-check target or equivalent command.
