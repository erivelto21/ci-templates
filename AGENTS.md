# AGENTS.md

## Repository purpose

This repository centralizes reusable CI/CD pipeline scripts, templates, and helper automation. Treat it as shared infrastructure: changes should be generic, documented, and safe to reuse across multiple repositories.

## Working guidelines

- Prefer reusable scripts and templates over project-specific one-offs.
- Keep scripts idempotent when possible so they are safe to re-run in CI.
- Use clear names that describe the pipeline stage or platform, such as `build`, `test`, `release`, `docker`, or `deploy`.
- Avoid hardcoding repository-specific values, secrets, tokens, branch names, or environment-specific paths.
- Read configuration from environment variables and document every required variable near the script or template that uses it.
- Fail fast with clear error messages when required tools, files, or environment variables are missing.

## Suggested structure

- `scripts/`: executable helper scripts used by pipelines.
- `templates/`: reusable workflow, job, or pipeline templates.
- `examples/`: minimal examples showing how to consume the scripts/templates.
- `docs/`: usage notes, required environment variables, and migration guides.

## Script standards

- Start shell scripts with `#!/usr/bin/env bash` and use `set -euo pipefail`.
- Quote variables in shell scripts unless word splitting is intentional.
- Keep scripts POSIX-compatible only when that is an explicit goal; otherwise document Bash requirements.
- Prefer small composable scripts over large scripts with many unrelated responsibilities.
- Add concise comments only for non-obvious behavior or important safety constraints.

## Validation

- Run the smallest relevant validation for the changed file before finishing.
- For shell scripts, prefer `shellcheck` if it is already available in the repo or environment.
- For workflow/template changes, validate syntax with the corresponding ecosystem tool when available.

## Documentation expectations

Every reusable script or template should document:

- What it does.
- Required inputs and environment variables.
- Optional inputs and defaults.
- Example usage from another repository.
- Expected outputs or side effects.
