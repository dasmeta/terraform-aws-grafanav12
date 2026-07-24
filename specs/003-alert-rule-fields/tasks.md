# Tasks: Alert Rule Field Preservation

**Input**: Design documents from `/specs/003-alert-rule-fields/`  
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/alert-input-contract.md

## Phase 1: Setup

- [x] T001 Create feature branch and Spec Kit package for alert rule field preservation.

## Phase 2: Contract Update

- [x] T002 [US1] Add downstream-compatible custom alert rule fields to `variables.tf`.
- [x] T003 [US2] Add downstream-compatible `alerts.disk_capacity` fields to `variables.tf`.

## Phase 3: Fixture Coverage

- [x] T004 [US1] Add VictoriaMetrics custom alert rule coverage to `tests/base-with-victoria-metrics/1-example.tf`.
- [x] T005 [US1] Add Loki custom alert rule coverage to `tests/base-with-victoria-metrics/1-example.tf`.
- [x] T006 [US2] Add disk-capacity alert coverage to `tests/base-with-victoria-metrics/1-example.tf`.

## Phase 4: Documentation And Verification

- [x] T007 Regenerate or update README input documentation.
- [x] T008 Run Terraform formatting and validation checks.
