## Context

This repository provides reusable CI templates, so the publish flow should stay generic and secure. The consumer repo already stores the API image coordinates in its Makefile, but CI should not depend on mutable tags or repository-specific shell glue.

## Goals / Non-Goals

**Goals:**
- Publish only the API image after merges to `main`.
- Use an immutable commit-SHA image tag.
- Keep registry access and image coordinates configurable.
- Keep the workflow simple enough to reuse in other repositories.

**Non-Goals:**
- Publishing crawler or front images.
- Introducing application-specific release logic.
- Adding mutable release tags such as `latest`.

## Decisions

- **Single publish job**: Use one job for checkout, login, build, and push. This keeps the workflow easy to reason about and avoids splitting a linear publish path into unnecessary pieces.
  - *Alternative considered*: separate build and push jobs. Rejected because the publish flow is already linear and a split would add overhead without improving reliability.

- **Commit-SHA tagging only**: Tag the image with the exact commit SHA from the workflow run.
  - *Alternative considered*: publish `latest` alongside SHA. Rejected because mutable tags weaken traceability and are not needed for a post-merge publish path.

- **Externalized configuration**: Accept registry, namespace, image name, Dockerfile path, and build context from workflow inputs or documented environment variables.
  - *Alternative considered*: hardcode the values from the consumer Makefile. Rejected because this template repo must remain reusable.

- **Use registry credentials from secrets**: Authenticate through GitHub Actions secrets or equivalent external secret sources, never from checked-in files.
  - *Alternative considered*: embed registry auth in repository configuration. Rejected for security and reuse reasons.

- **Push only after a successful build**: Build and push in the same publish path so a failed build cannot produce a partial release state.
  - *Alternative considered*: build artifacts separately and promote them later. Rejected because it adds release complexity that is unnecessary for this workflow.

## Risks / Trade-offs

- [Risk] A bad commit on `main` will still publish if it merges successfully → [Mitigation] keep the workflow limited to trusted branches and require normal branch protection.
- [Risk] Registry credentials may be misconfigured in a consumer repo → [Mitigation] fail fast during login and document the required secrets clearly.
- [Risk] Immutable tags can accumulate quickly → [Mitigation] rely on registry retention policies outside the workflow.

## Migration Plan

1. Add the reusable workflow template and docs in this repository.
2. Update consuming repositories to pass the registry inputs and secrets expected by the workflow.
3. Switch the consumer repository to trigger the publish workflow on `push` to `main`.
4. Validate a first publish in a non-production repository or branch, then roll the same pattern to production consumers.

Rollback strategy: disable the `main` branch trigger in the consumer repository or remove the workflow reference; no application runtime migration is required.

## Open Questions

- Should consumers invoke the reusable workflow directly, or should this template also provide a ready-to-use example workflow?
- Which registry types must be documented first: Docker Hub, GHCR, or a private registry?
