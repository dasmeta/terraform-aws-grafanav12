# Feature Specification: Bump On-Premise Grafana Dependency to 1.32.0

**Feature Branch**: `feat/bump-onpremise-grafana-v1320`
**Created**: 2026-10-15
**Status**: Ready for implementation
**Input**: Update `dasmeta/grafanav12/aws` to consume released `dasmeta/grafana/onpremise` version `1.32.0`.

## User Scenario

### Consume the released compatibility fix (Priority: P1)

An AWS Grafana wrapper consumer can select the next wrapper release and receive the published on-premise Grafana `1.32.0` compatibility fix without changing its configuration.

**Independent Test**: The wrapper's sole nested `dasmeta/grafana/onpremise` reference resolves to exactly `1.32.0`, while the wrapper interface and AWS-specific resources are unchanged.

**Acceptance Scenarios**:

1. **Given** the wrapper currently pins `1.30.0`, **when** the update is applied, **then** `module.this` pins `1.32.0`.
2. **Given** an existing wrapper consumer, **when** it upgrades to the next wrapper release, **then** no new wrapper input or provider dependency is required.

## Requirements

- **FR-001**: `main.tf` MUST reference `dasmeta/grafana/onpremise` version `1.32.0`.
- **FR-002**: The change MUST preserve all wrapper inputs, outputs, resources, and provider constraints.
- **FR-003**: README dependency references MUST match the source pin.
- **FR-004**: The wrapper MUST be released before a consumer pin is changed.

## Success Criteria

- **SC-001**: The only Terraform source change is the nested module version from `1.30.0` to `1.32.0`.
- **SC-002**: Terraform formatting and validation pass.
- **SC-003**: Existing wrapper test fixtures require no interface changes.

## Assumptions

- Version `1.32.0` is published.
- This is a compatible child-module update.
- Publishing the wrapper and updating consumer IaC are separate follow-up steps.
