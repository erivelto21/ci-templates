# go-pr-workflow

## Purpose

Provide a reusable Go pull request workflow that validates code in parallel, builds only after validation succeeds, and runs tests after a successful build.

## Requirements

### Requirement: Parallel validation jobs
The workflow MUST run format verification, lint, and tidy as separate jobs that can execute in parallel on pull requests.

#### Scenario: Validation starts in parallel
- **WHEN** a pull request is opened or updated
- **THEN** format verification, lint, and tidy begin without waiting on each other

### Requirement: Serialized build job
The workflow MUST run the build job only after format verification, lint, and tidy succeed.

#### Scenario: Build waits for validation
- **WHEN** any of format verification, lint, or tidy fails
- **THEN** the build job does not start

### Requirement: Parallel test jobs
The workflow MUST run test, test-race, and test-cover as separate jobs that can execute in parallel after build succeeds.

#### Scenario: Tests fan out after build
- **WHEN** build completes successfully
- **THEN** test, test-race, and test-cover start without waiting on each other

### Requirement: Non-mutating format verification
The workflow MUST verify formatting without rewriting files.

#### Scenario: Formatting is out of compliance
- **WHEN** a repository contains files that would change under the formatter
- **THEN** the format verification job fails

### Requirement: Reusable command model
The workflow MUST rely on documented Go repository commands or standard equivalents so it can be reused across repositories.

#### Scenario: Consumer adapts command names
- **WHEN** a repository uses different command names for validation
- **THEN** the workflow can be mapped to those commands without changing the validation model
