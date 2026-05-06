# Tasks: Ignore Public ACLs Support

**Input**: Design documents from `/Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12/specs/002-ignore-public-acls/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/s3-public-access-inputs.md, quickstart.md

**Tests**: Include Terraform validation tasks because the specification requires the new inputs to work in examples and documentation.

**Organization**: Tasks are grouped by user story to keep each part independently testable.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: User story label (`[US1]`, `[US2]`, `[US3]`)
- Every task includes an exact file path

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm current Loki/Tempo bucket wiring and example coverage before editing.

- [ ] T001 Review current Loki and Tempo bucket module inputs in `/Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12/main.tf`
- [ ] T002 [P] Review Loki and Tempo type definitions in `/Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12/variables.tf`
- [ ] T003 [P] Review existing example coverage in `/Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12/tests/base/1-example.tf` and `/Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12/tests/base-with-victoria-metrics/1-example.tf`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Prepare shared repo artifacts needed before implementation and validation.

- [ ] T004 Create Speckit feature tracking files in `/Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12/specs/002-ignore-public-acls/`
- [ ] T005 Create Terraform packaging ignore file in `/Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12/.terraformignore`

**Checkpoint**: Implementation can begin.

---

## Phase 3: User Story 1 - Configure Loki bucket ACL handling (Priority: P1) 🎯 MVP

**Goal**: Allow consumers to set `loki_stack.send_logs_s3.ignore_public_acls` and pass it into the managed Loki bucket.

**Independent Test**: The Loki input type accepts the field and root module wiring passes it to `module.loki_bucket`.

### Implementation for User Story 1

- [ ] T006 [US1] Add `ignore_public_acls` to the Loki bucket settings object in `/Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12/variables.tf`
- [ ] T007 [US1] Pass the Loki `ignore_public_acls` value to `module.loki_bucket` in `/Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12/main.tf`
- [ ] T008 [US1] Demonstrate the Loki input in `/Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12/tests/base/1-example.tf`

**Checkpoint**: Loki support is complete and testable independently.

---

## Phase 4: User Story 2 - Configure Tempo bucket ACL handling (Priority: P2)

**Goal**: Allow consumers to set `tempo.ignore_public_acls` and pass it into the managed Tempo bucket.

**Independent Test**: The Tempo input type accepts the field and root module wiring passes it to `module.tempo_bucket`.

### Implementation for User Story 2

- [ ] T009 [US2] Add `ignore_public_acls` to the Tempo object in `/Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12/variables.tf`
- [ ] T010 [US2] Pass the Tempo `ignore_public_acls` value to `module.tempo_bucket` in `/Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12/main.tf`
- [ ] T011 [US2] Demonstrate the Tempo input in `/Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12/tests/base-with-victoria-metrics/1-example.tf`

**Checkpoint**: Tempo support is complete and testable independently.

---

## Phase 5: User Story 3 - Discover and validate the new inputs (Priority: P3)

**Goal**: Document the new inputs and validate example scenarios.

**Independent Test**: A reader can find the inputs in README and Terraform validation succeeds for the updated examples.

### Implementation for User Story 3

- [ ] T012 [US3] Document both input paths and a usage snippet in `/Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12/README.md`
- [ ] T013 [US3] Align generated Terraform docs output in `/Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12/README.md`
- [ ] T014 [US3] Run validation for the updated module and example scenarios from `/Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12`

**Checkpoint**: The feature is documented and validated.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final consistency checks across spec, code, and examples.

- [ ] T015 [P] Mark completed implementation tasks in `/Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12/specs/002-ignore-public-acls/tasks.md`
- [ ] T016 Verify quickstart accuracy in `/Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12/specs/002-ignore-public-acls/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1) has no dependencies.
- Foundational (Phase 2) depends on Setup.
- US1 starts after Foundational.
- US2 starts after Foundational and can share `variables.tf`/`main.tf` work with US1 sequentially.
- US3 depends on the implemented code paths being stable.

### User Story Dependencies

- **US1 (P1)**: No dependency on other stories.
- **US2 (P2)**: No conceptual dependency on US1, but edits touch the same root files and should be applied in one sequential patch set.
- **US3 (P3)**: Depends on US1 and US2 so docs and validations reflect the final interface.

### Parallel Opportunities

- T002 and T003 can run in parallel.
- T015 can run in parallel with final documentation review.

## Notes

- Keep the interface expansion minimal.
- Do not introduce a new top-level shared S3 settings object.
- Preserve existing example structure; only add the new input fields where relevant.
