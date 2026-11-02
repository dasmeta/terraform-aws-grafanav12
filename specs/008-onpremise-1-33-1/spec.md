# Feature Specification: AWS Grafana Wrapper On-Premise 1.33.1 Compatibility

**Feature Branch**: `008-onpremise-1-33-1`  
**Created**: 2026-11-02  
**Status**: Approved  
**Input**: Update the AWS Grafana wrapper for on-premise Grafana `1.33.1` and preserve heterogeneous application dashboard rows.

## User Scenarios & Testing

### User Story 1 - Upgrade without rewriting dashboards (Priority: P1)

An AWS Grafana wrapper consumer upgrades to the next wrapper release and keeps application dashboards whose block rows have different shapes.

**Independent Test**: A native Terraform test plans the root wrapper with service, AWS SES, and SLA rows without a type-conversion error.

**Acceptance Scenarios**:

1. **Given** a consumer with heterogeneous dashboard rows, **When** it plans the wrapper, **Then** Terraform accepts the input and forwards it to on-premise Grafana `1.33.1`.
2. **Given** an existing homogeneous dashboard, **When** it upgrades, **Then** the wrapper's existing inputs and AWS resources are unchanged.

### Edge Cases

- Dashboard entries may differ in their optional defaults and block-specific row fields.
- The target on-premise module version must resolve from the Terraform Registry.

## Requirements

- **FR-001**: Both on-premise Grafana module references in `main.tf` MUST use version `1.33.1`.
- **FR-002**: `application_dashboard` MUST accept heterogeneous dashboard and row objects without consumer padding.
- **FR-003**: The existing AWS wrapper input defaults MUST remain available after relaxing its type.
- **FR-004**: The README MUST document the `1.33.1` pin and heterogeneous dashboard compatibility.
- **FR-005**: A native regression test MUST cover mixed dashboard row shapes.

## Success Criteria

- **SC-001**: `terraform init -backend=false` resolves on-premise Grafana `1.33.1`.
- **SC-002**: The mixed-row regression test passes.
- **SC-003**: Terraform formatting, validation, and repository checks pass.

## Assumptions

- Version `1.33.1` is a published Terraform Registry release, as supplied by the requester.
- This is a backward-compatible wrapper update; no new AWS capability or provider constraint is introduced.
