# Tasks: Bump Grafana On-Premise Dependency

**Input**: [spec.md](spec.md), [plan.md](plan.md), [research.md](research.md), [data-model.md](data-model.md), and [quickstart.md](quickstart.md)

## Phase 1: Setup

- [X] T001 Create bounded Speckit evidence in `specs/003-bump-onpremise-1-28-3/`
- [X] T002 Confirm published child release v1.28.3 and current wrapper dependency in `main.tf`

## Phase 2: User Story 1 - Consume the corrected alert behavior (Priority: P1)

**Goal**: Make the next AWS wrapper release consume the corrected underlying Grafana module.

**Independent Test**: `main.tf` references only `dasmeta/grafana/onpremise` v1.28.3 and the wrapper interface remains unchanged.

- [X] T003 [US1] Update the nested Grafana module version in `main.tf` from `1.28.0` to `1.28.3`
- [X] T004 [US1] Verify the exact dependency reference in `main.tf` and preserve the remaining module arguments

## Phase 3: Validation and Release Handoff

- [X] T005 Run `terraform fmt -check` for the Terraform files in the repository root
- [ ] T006 Run `terraform init -backend=false` and `terraform validate` in the repository root; record any provider-architecture limitation (blocked: `deepmerge` provider function cannot load locally)
- [X] T007 Review `git diff --check` and the scoped diff before preparing a wrapper release
- [X] T008 Hand off the next wrapper release and the two downstream Ben Energy YAML pin updates

## Dependencies & Execution Order

T003 and T004 deliver the single user story. T005–T008 depend on T003 and T004.

## Implementation Strategy

Apply the one-line version pin update first, verify static formatting and resolution, then release the wrapper before updating a consumer pin. No consumer configuration changes occur in this repository.
