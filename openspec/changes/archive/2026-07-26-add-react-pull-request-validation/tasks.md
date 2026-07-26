## 1. Workflow Implementation

- [x] 1.1 Add `.github/workflows/validate-pull-request-react.yml` with `pull_request` and `workflow_call` triggers.
- [x] 1.2 Keep commit validation outside the React workflow and compose it in consumer examples.
- [x] 1.3 Add an install job that checks out the repository, sets up Node.js with npm caching, and runs the fixed install command.
- [x] 1.4 Add build, format verification, lint, type check, test, and test coverage jobs that all depend on install and can run in parallel.
- [x] 1.5 Ensure the format verification job uses a non-mutating check command rather than rewriting files.

## 2. Documentation and Examples

- [x] 2.1 Update README documentation to list the React pull request validation workflow and its fixed commands.
- [x] 2.2 Rename the composed Go CI example and add a composed React CI example.
- [x] 2.3 Document the expected job order for standalone React validation and composed commit-plus-React validation.

## 3. Validation

- [x] 3.1 Validate the workflow YAML syntax with an available workflow or YAML validation tool.
- [x] 3.2 Verify the OpenSpec change with `openspec validate add-react-pull-request-validation --strict`.
- [x] 3.3 Review the final dependency graph to confirm React checks cannot run before install succeeds, and composed examples gate validation behind commit lint.
