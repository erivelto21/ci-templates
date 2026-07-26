## ADDED Requirements

### Requirement: Commit validation composition
The React CI consumer example MUST validate pull request commit messages before invoking the React validation workflow.

#### Scenario: Commit validation fails
- **WHEN** pull request commit message validation fails
- **THEN** the React validation workflow does not start

### Requirement: Install before React validation fan-out
The workflow MUST run the React dependency installation job before build, format verification, lint, type check, test, and coverage jobs.

#### Scenario: React validation starts
- **WHEN** the React validation workflow starts
- **THEN** the install job starts before build, format verification, lint, type check, test, and coverage

### Requirement: Parallel React validation jobs
The workflow MUST run build, format verification, lint, type check, test, and coverage as separate jobs that can execute in parallel after install succeeds.

#### Scenario: Install succeeds
- **WHEN** the install job completes successfully
- **THEN** build, format verification, lint, type check, test, and coverage start without waiting on each other

### Requirement: Install failure blocks React checks
The workflow MUST prevent React validation jobs from running when dependency installation fails.

#### Scenario: Install fails
- **WHEN** the install job fails
- **THEN** build, format verification, lint, type check, test, and coverage do not start

### Requirement: Non-mutating format verification
The workflow MUST verify React formatting without rewriting files in the pull request workspace.

#### Scenario: Formatting is out of compliance
- **WHEN** the React source contains files that do not match the configured formatter
- **THEN** the format verification job fails and reports the formatting issue

### Requirement: Fixed React command model
The workflow MUST use fixed npm commands for install, build, format verification, lint, type checking, tests, and coverage.

#### Scenario: Consumer repository uses expected npm scripts
- **WHEN** a React repository defines the expected npm scripts
- **THEN** the workflow validates the pull request without requiring workflow inputs

### Requirement: Reusable workflow triggers
The workflow MUST support both direct pull request execution and invocation as a reusable workflow.

#### Scenario: Workflow is called by a consumer repository
- **WHEN** a repository calls the React validation workflow with `workflow_call`
- **THEN** the workflow runs the same commit, install, and React validation gates used for direct pull request execution
