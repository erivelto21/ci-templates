# kubernetes-deploy

## Purpose

Provide a reusable workflow for deploying a published image to a Kubernetes cluster via Helm, using kubeconfig authentication and a Helm chart from an infrastructure repository.

## Requirements

### Requirement: Deploy published image via Helm
The workflow MUST deploy a previously published image to a Kubernetes cluster using `helm upgrade --install`, injecting the image repository and tag into the chart.

#### Scenario: Successful deployment
- **WHEN** the workflow runs with a valid chart, release name, namespace, and image reference
- **THEN** the workflow runs `helm upgrade --install` with `image.repository` and `image.tag` set from the resolved image reference

#### Scenario: Release already exists
- **WHEN** a release with the same name already exists in the namespace
- **THEN** the workflow upgrades the existing release instead of failing

### Requirement: Kubernetes authentication via kubeconfig
The workflow MUST authenticate to the cluster using a kubeconfig supplied as a single base64-encoded secret, written to the runner's kubeconfig path.

#### Scenario: Kubeconfig secret provided
- **WHEN** a valid base64 kubeconfig secret is provided
- **THEN** the workflow writes it to the runner's kubeconfig location and can reach the cluster

#### Scenario: Kubeconfig missing or invalid
- **WHEN** the kubeconfig secret is missing or cannot be decoded
- **THEN** the workflow fails with a clear error before attempting any cluster operation

### Requirement: Chart from infrastructure repository
The workflow MUST obtain the Helm chart by checking out an infrastructure repository using a token with read access, and locate the chart by a configurable path.

#### Scenario: Chart checkout succeeds
- **WHEN** the infrastructure repository and chart path are configured and the token has read access
- **THEN** the workflow checks out the repository and uses the chart at the configured path

#### Scenario: Chart checkout fails
- **WHEN** the token lacks access or the chart path does not exist
- **THEN** the workflow fails with a clear error

### Requirement: Shared image reference resolution
The workflow MUST resolve the image reference (`<registry>/<namespace>/<image>:<sha>`) using the same shared script as the publish workflow, emitting the repository and tag separately.

#### Scenario: Image reference resolved
- **WHEN** registry, namespace, image name, and commit SHA are available
- **THEN** the workflow resolves the repository and tag from the shared script and uses them for the Helm deployment

#### Scenario: Required image variables missing
- **WHEN** registry or image name variables are not configured
- **THEN** the workflow fails with a clear error

### Requirement: Image pull secret for private registry
The workflow MUST create or update a `kubernetes.io/dockerconfigjson` secret in the target namespace from the registry credentials, idempotently, before deploying.

#### Scenario: Image pull secret created
- **WHEN** the workflow runs with registry credentials and a configured secret name
- **THEN** the secret exists in the target namespace with the registry credentials

#### Scenario: Image pull secret already exists
- **WHEN** the secret already exists in the target namespace
- **THEN** the workflow updates it without failing

### Requirement: Rollout verification
The workflow MUST verify that the deployment rollout completes after the Helm upgrade and fail if it does not.

#### Scenario: Rollout completes
- **WHEN** the deployment becomes ready within the timeout
- **THEN** the workflow reports the deployment as successful

#### Scenario: Rollout fails
- **WHEN** the deployment does not become ready within the timeout (for example, due to `ImagePullBackOff`)
- **THEN** the workflow fails and reports the deployment as unsuccessful

### Requirement: Externalized deployment configuration
The workflow MUST obtain chart path, release name, namespace, and all credentials from inputs, variables, or secrets, without hardcoding repository-specific values.

#### Scenario: Consumer configures its own deployment
- **WHEN** a repository provides its chart path, release name, namespace, and credentials
- **THEN** the workflow deploys to that repository's target without editing workflow logic
