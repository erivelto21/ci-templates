## Context

This repository already provides reusable CI templates for pull request commit message validation and Go pull request validation. React applications need a comparable reusable workflow that can be consumed from application repositories while keeping the dependency graph explicit and efficient.

The referenced React frontend Makefile exposes the validation commands as `install`, `build`, `fmt`, `lint`, `type-check`, `test`, and `test-coverage`. The workflow should map to those commands without embedding project-specific paths or secrets.

## Goals / Non-Goals

**Goals:**

- Provide a reusable React pull request validation workflow triggered by `pull_request` and `workflow_call`.
- Keep commit message validation composed in consumer CI examples rather than embedded in the React reusable workflow.
- Run dependency installation before the React validation fan-out.
- Fan out build, format verification, lint, type check, tests, and coverage after install succeeds.
- Keep formatting verification non-mutating in CI.
- Document how React repositories should consume the workflow and which commands they must provide.

**Non-Goals:**

- Do not add React application source code or repository-specific configuration.
- Do not replace or modify the existing Go pull request validation workflow.
- Do not include end-to-end tests unless a future change explicitly scopes them in.
- Do not publish artifacts, coverage reports, or deployment outputs as part of this workflow.

## Decisions

### Keep commit validation in composed examples

The React reusable workflow will not include its own commit validation job. Consumer CI examples will compose the existing commit message workflow before React validation, matching the current Go CI composition pattern.

Alternative considered: embed commit validation directly inside the React reusable workflow. That makes one workflow enforce the whole chain, but it duplicates the existing reusable commit validation workflow and makes the first React template less focused.

### Use a dedicated install gate

The workflow will have an `install` job that checks out the repository, sets up Node.js 22 with npm caching, and runs `npm install`. All validation jobs depend on `install`.

Alternative considered: repeat install in every validation job with no install gate. GitHub Actions jobs are isolated, so each validation job may still need its own dependency setup during implementation, but the explicit install gate preserves the requested orchestration and fails fast before fanning out expensive checks.

### Fan out independent validation checks after install

The jobs `build`, `format-check`, `lint`, `type-check`, `test`, and `test-coverage` will all depend on `install` and not on each other. This matches the requested parallelism and avoids serializing independent checks.

Alternative considered: make `test-coverage` depend on `test` to avoid generating coverage when tests fail. This saves some CI time in failing cases but reduces parallelism and delays feedback, so the default design keeps both test jobs parallel.

### Verify formatting without rewriting files

The workflow will use a non-mutating formatter check command instead of the Makefile `fmt` target if that target formats files in place. The expected command should be documented so consumers can provide an equivalent npm script.

Alternative considered: run `make fmt` and check for a clean git diff afterward. That detects formatting drift, but it mutates the workspace during CI and is less clear than a dedicated check command.

### Keep commands fixed for the first version

The first React workflow version will use fixed npm-oriented commands aligned with the Makefile targets. Inputs for package manager, working directory, Node.js version, or command overrides can be added later when there is a concrete reuse need.

## Risks / Trade-offs

- Install gate plus isolated jobs can duplicate dependency installation work -> Use Node/npm caching and keep the graph explicit; optimize further only if CI time becomes a problem.
- `test` and `test-coverage` may execute overlapping test suites -> Keep them parallel for faster feedback; consumers can later request serialized coverage if cost becomes a concern.
- Consumer projects may not have a non-mutating format script -> Document the expected command and fail clearly when it is missing.
- Different package managers or working directories may be used by React projects -> Start with fixed root-level npm commands because the first version should be simple; add configuration later if needed.
