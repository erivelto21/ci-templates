# Design

## Goal

Provide a clean, reusable pull request workflow for Go projects with a simple job graph and clear failure boundaries.

## Job Graph

```text
format-check ─┐
lint          ├──> build ───> test
tidy          ┘              ├──> test-race
                             └──> test-cover
```

## Decisions

- Use one job per validation step so failures are isolated and parallelism is preserved.
- Keep `build` serialized after the initial validation jobs to avoid spending build time on obviously broken changes.
- Run the three test jobs after `build` to ensure the compiled application is in a good state before broad test execution.
- Treat formatting as verification, not mutation. CI must fail when formatting is not compliant.
- Prefer simple, explicit commands over a matrix when the goal is readability and stable job naming.

## Format Verification

The workflow should not run a write-style formatter in CI. It should verify formatting with a non-mutating check, either through a dedicated repository target such as `make fmt-check` or an equivalent command sequence that fails when files need formatting.

## Reuse

The template should remain generic and rely on standard Go tooling and conventional Make targets. Repository-specific values, paths, and secret inputs should stay out of the template.
