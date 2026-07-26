## Why

React applications need a reusable pull request validation workflow equivalent to the existing Go validation workflow so repositories can enforce consistent frontend quality gates from the shared CI templates.

The workflow should fail fast on invalid commit messages, install dependencies once per job, and organize independent React checks so they can run in parallel after setup.

## What Changes

- Add a reusable GitHub Actions workflow for React pull request validation.
- Reuse the existing pull request commit message validation as the first required gate.
- Add React validation jobs for dependency installation, build, formatting verification, linting, TypeScript type checking, tests, and coverage.
- Define job dependencies so install runs only after commit validation succeeds, and independent validation checks run after install.
- Document the workflow usage and expected React project commands.

## Capabilities

### New Capabilities

- `react-pr-workflow`: Reusable pull request validation workflow for React applications, including commit validation, dependency installation, build, format verification, lint, type check, tests, and coverage.

### Modified Capabilities

- None.

## Impact

- Adds a new reusable workflow under `.github/workflows/`.
- Adds or updates documentation and examples for consuming the React pull request validation workflow.
- Depends on existing Node.js/npm commands in consumer React projects, aligned with the referenced frontend Makefile targets.
- Does not change existing Go, commit message, or image publishing workflows.
