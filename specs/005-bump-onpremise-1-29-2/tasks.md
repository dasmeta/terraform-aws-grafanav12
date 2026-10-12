# Tasks: Bump On-Premise Grafana Dependency to 1.29.2

## Phase 1: Evidence

- [x] T001 Create the bounded Speckit package under `specs/005-bump-onpremise-1-29-2/`.
- [x] T002 Confirm the current wrapper pin is `1.29.1` and the target release is `1.29.2`.

## Phase 2: Dependency Update

- [x] T003 Update the `dasmeta/grafana/onpremise` version in `main.tf` to `1.29.2`.
- [x] T004 Update README module-version documentation and the wrapper dependency sentence.

## Phase 3: Validation and Handoff

- [x] T005 Run formatting, initialization, validation, pre-commit, and scoped-diff checks.
- [ ] T006 Commit and push the wrapper patch branch for review.
- [ ] T007 Publish a wrapper patch release, then update the consumer pin in a separate change.
