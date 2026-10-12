# Feature Specification: Bump On-Premise Grafana Dependency to 1.29.2

**Feature Branch**: `fix/bump-onpremise-1-29-2`
**Created**: 2026-10-12
**Status**: Ready for implementation
**Input**: Update `dasmeta/grafanav12/aws` to consume released `dasmeta/grafana/onpremise` version `1.29.2`.

## User Scenario

### Consume the released compatibility fix (Priority: P1)

An AWS Grafana wrapper consumer can select the next wrapper release and receive the published on-premise Grafana `1.29.2` compatibility fix without changing its configuration.

**Independent Test**: The wrapper's sole nested `dasmeta/grafana/onpremise` reference resolves to exactly `1.29.2`, while the wrapper interface and AWS-specific resources are unchanged.

**Acceptance Scenarios**:

1. **Given** the wrapper currently pins `1.29.1`, **when** the update is applied, **then** `module.this` pins `1.29.2`.
2. **Given** an existing wrapper consumer, **when** it upgrades to the next wrapper release, **then** no new wrapper input or provider dependency is required.

## Requirements

- **FR-001**: `main.tf` MUST reference `dasmeta/grafana/onpremise` version `1.29.2`.
- **FR-002**: The change MUST preserve all wrapper inputs, outputs, resources, and provider constraints.
- **FR-003**: README dependency references MUST match the source pin.
- **FR-004**: The wrapper MUST be released before a consumer pin is changed.

## Success Criteria

- **SC-001**: The only Terraform source change is the nested module version from `1.29.1` to `1.29.2`.
- **SC-002**: Terraform formatting and validation pass.
- **SC-003**: Existing wrapper test fixtures require no interface changes.

## Assumptions

- Version `1.29.2` is published.
- This is a patch-compatible child-module update.
- Publishing the wrapper and updating consumer IaC are separate follow-up steps.
