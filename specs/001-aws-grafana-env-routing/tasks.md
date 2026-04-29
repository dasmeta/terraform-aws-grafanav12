# Tasks: AWS Grafana Env Routing Parity

**Input**: Design documents from `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/specs/001-aws-grafana-env-routing/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/routing-input-contract.md, quickstart.md

**Tests**: Include Terraform validation tasks because the specification explicitly requires `terraform init`/`terraform validate` for the dedicated routing scenario.

**Organization**: Tasks are grouped by user story to keep each story independently implementable and testable.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: User story label (`[US1]`, `[US2]`, `[US3]`)
- Every task includes an exact file path

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm baseline and prepare documentation/test scaffold locations.

- [X] T001 Review current wrapped module pin in `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/main.tf` and capture target upgrade version from release context
- [X] T002 [P] Inspect parity reference scenario in `/Users/tmuradyan/projects/dasmeta/terraform-onpremise-grafana/tests/multi-environment-alert-routing/1-example.tf` for AWS adaptation inputs
- [X] T003 [P] Confirm existing baseline tests remain unchanged by reviewing `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/tests/base/1-example.tf`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create shared foundation for all user stories.

**⚠️ CRITICAL**: No user-story completion claims before this phase is done.

- [X] T004 Create dedicated scenario directory and base setup file at `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/tests/multi-environment-alert-routing/0-setup.tf`
- [X] T005 [P] Create scenario README scaffold at `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/tests/multi-environment-alert-routing/README.md`
- [X] T006 [P] Create routing scenario implementation scaffold at `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/tests/multi-environment-alert-routing/1-example.tf`

**Checkpoint**: Foundation ready for story work.

---

## Phase 3: User Story 1 - Upgrade dependency for routing parity (Priority: P1) 🎯 MVP

**Goal**: Upgrade wrapped onprem module version so AWS wrapper inherits same-cluster env routing capabilities without input-breaking changes.

**Independent Test**: Module pin is updated in `main.tf` and routing-related pass-through (`alerts`) remains unchanged/compatible.

### Implementation for User Story 1

- [X] T007 [US1] Update wrapped module version pin in `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/main.tf`
- [X] T008 [US1] Verify no interface changes are introduced in `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/variables.tf` for matcher-based routing compatibility
- [X] T009 [US1] Run Terraform validation for module root from `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12` (init/validate) and record results in implementation notes

**Checkpoint**: US1 complete; AWS wrapper dependency parity is in place.

---

## Phase 4: User Story 2 - Provide dedicated AWS routing example/test (Priority: P2)

**Goal**: Deliver a dedicated AWS test/example proving matcher-based env routing and fallback behavior.

**Independent Test**: `terraform init` and `terraform validate` pass in the dedicated scenario folder and show env matcher + fallback configuration.

### Tests for User Story 2

- [X] T010 [US2] Run `terraform init` in `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/tests/multi-environment-alert-routing`
- [X] T011 [US2] Run `terraform validate` in `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/tests/multi-environment-alert-routing`

### Implementation for User Story 2

- [X] T012 [US2] Implement AWS routing example with `env` matcher policies and fallback contact point in `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/tests/multi-environment-alert-routing/1-example.tf`
- [X] T013 [US2] Configure scenario providers/locals/inputs required to run the example in `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/tests/multi-environment-alert-routing/0-setup.tf`
- [X] T014 [US2] Document scenario intent and usage in `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/tests/multi-environment-alert-routing/README.md`

**Checkpoint**: US2 complete; dedicated scenario validates independently and does not repurpose base tests.

---

## Phase 5: User Story 3 - Document upgrade and usage path (Priority: P3)

**Goal**: Document dependency upgrade purpose and AWS usage pattern for matcher-based environment routing.

**Independent Test**: A reader can follow README guidance to find the dedicated scenario and configure matcher-based routing with fallback.

### Implementation for User Story 3

- [X] T015 [US3] Update module documentation with dependency parity note and example path in `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/README.md`
- [X] T016 [US3] Add matcher-based same-cluster routing usage example (including fallback contact point) in `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/README.md`
- [X] T017 [US3] Align generated module docs table/module version references in `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/README.md`

**Checkpoint**: US3 complete; docs fully cover upgrade purpose and usage.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final consistency checks across all stories.

- [X] T018 [P] Re-run dedicated scenario validation (`terraform init && terraform validate`) in `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/tests/multi-environment-alert-routing`
- [X] T019 [P] Confirm baseline scenario remains unchanged by validating `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/tests/base`
- [X] T020 Verify quickstart steps and adjust `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/specs/001-aws-grafana-env-routing/quickstart.md` if execution details changed during implementation

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1) has no dependencies.
- Foundational (Phase 2) depends on Setup and blocks all story phases.
- User stories run in priority order for MVP delivery: US1 → US2 → US3.
- Polish (Phase 6) depends on completion of selected user stories.

### User Story Dependencies

- **US1 (P1)**: Starts after Foundational; no dependency on US2/US3.
- **US2 (P2)**: Depends on US1 version parity to ensure scenario uses final dependency behavior.
- **US3 (P3)**: Depends on US1 and US2 so docs reflect actual implemented/tested behavior.

### Within Each User Story

- Validation commands follow implementation updates.
- Example/test files are completed before final scenario validation.
- Documentation is updated after implementation details are stable.

### Parallel Opportunities

- T002 and T003 can run in parallel in Setup.
- T005 and T006 can run in parallel in Foundational.
- T018 and T019 can run in parallel in Polish.

---

## Parallel Example: User Story 2

```bash
# After US1 is complete, prepare dedicated scenario files in parallel:
Task: "Create/update tests/multi-environment-alert-routing/0-setup.tf"
Task: "Create/update tests/multi-environment-alert-routing/README.md"

# Then implement and validate:
Task: "Implement matcher routing example in tests/multi-environment-alert-routing/1-example.tf"
Task: "Run terraform init && terraform validate in tests/multi-environment-alert-routing"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2.
2. Complete US1 (dependency pin + compatibility verification).
3. Validate module root.
4. Stop for review before adding new scenario/docs.

### Incremental Delivery

1. Deliver US1 (parity dependency upgrade).
2. Deliver US2 (dedicated AWS scenario + validation).
3. Deliver US3 (README guidance).
4. Run cross-cutting polish validations.

### Parallel Team Strategy

1. One contributor handles dependency/version update (US1).
2. One contributor prepares scenario files (US2 scaffolding).
3. Documentation updates proceed after US2 config is stable.

---

## Notes

- All tasks follow strict checklist format with IDs and file paths.
- Story labels are used only in user-story phases.
- No `environment_routing` wrapper should be introduced; matcher-based routing is canonical.
