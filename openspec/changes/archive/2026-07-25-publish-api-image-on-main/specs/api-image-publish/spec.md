## ADDED Requirements

### Requirement: Publish on main branch updates
The workflow MUST publish the API image when commits are pushed to the `main` branch after merge.

#### Scenario: Merge reaches main
- **WHEN** a merge commit or fast-forward update lands on `main`
- **THEN** the workflow starts the API image publish process

### Requirement: Immutable image tag
The workflow MUST tag the published API image with the commit SHA used for the run.

#### Scenario: Tag is derived from the commit
- **WHEN** the workflow runs for a specific commit
- **THEN** the pushed image tag is exactly that commit SHA

### Requirement: Registry authentication
The workflow MUST authenticate to the target registry using externally supplied credentials or secrets.

#### Scenario: Registry login succeeds
- **WHEN** valid registry credentials are provided
- **THEN** the workflow can push the image to the registry

### Requirement: Externalized image coordinates
The workflow MUST obtain registry, namespace, image name, Dockerfile path, and build context from inputs or documented environment variables.

#### Scenario: Consumer configures its own image target
- **WHEN** a repository provides its registry and image settings
- **THEN** the workflow publishes to that repository's target location without editing workflow logic

### Requirement: Fail on publish errors
The workflow MUST fail if the image build or push step fails.

#### Scenario: Build or push fails
- **WHEN** Docker build or registry push returns an error
- **THEN** the workflow fails and reports the publish as unsuccessful
