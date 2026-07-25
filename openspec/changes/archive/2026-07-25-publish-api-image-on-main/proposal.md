# Proposal: Publish API image on main

## Why

We need a reusable way to publish the application API image automatically after changes land on `main`. This removes manual release steps, keeps image publishing consistent across repositories, and lets consumers reuse the same secure CI pattern.

## What Changes

- Add a reusable workflow for publishing the API image after merges to `main`.
- Publish the API image with an immutable commit-SHA tag only.
- Keep registry credentials and image coordinates externalized through inputs or secrets.
- Document the expected registry variables and consumer usage.

## Capabilities

### New Capabilities
- `api-image-publish`: reusable API image publishing workflow for `main` branch merges.

### Modified Capabilities
- None.

## Impact

Adds a new reusable GitHub Actions workflow and supporting documentation in this template repository. Consumer repositories will need to provide registry settings, credentials, and the API Dockerfile/build context expected by the workflow.
