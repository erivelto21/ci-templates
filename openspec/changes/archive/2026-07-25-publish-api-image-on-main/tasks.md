## 1. Workflow template

- [x] 1.1 Create a reusable GitHub Actions workflow for publishing the API image on `push` to `main`
- [x] 1.2 Wire registry login, Docker build, and image push into a single secure publish job
- [x] 1.3 Tag the pushed image with the commit SHA only

## 2. Configuration and reuse

- [x] 2.1 Add workflow inputs or documented environment variables for registry, namespace, image name, Dockerfile path, and build context
- [x] 2.2 Add required secrets and permissions documentation for consumer repositories
- [x] 2.3 Provide a minimal example workflow showing how a consumer repository uses the publish template

## 3. Validation and documentation

- [x] 3.1 Document the publish flow, tagging strategy, and security expectations
- [x] 3.2 Validate the workflow syntax and example configuration
