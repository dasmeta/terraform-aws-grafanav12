# Feature Specification: Bump On-Premise Grafana Dependency to 1.32.1

**Feature Branch**: `008-bump-onpremise-1-32-1`
**Created**: 2026-10-16
**Status**: Approved for implementation
**Input**: Update the AWS Grafana wrapper to consume released `dasmeta/grafana/onpremise` version 1.32.1.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Consume the Scrape Fix (Priority: P1)

As an AWS Grafana wrapper consumer, I can select the next wrapper release and
receive the published standalone kube-state-metrics scrape fix without changing
my wrapper inputs.

**Why this priority**: The child release removes a duplicate legacy scrape
target while preserving its intended ServiceMonitor discovery path.

**Independent Test**: Initialize the wrapper and confirm its single
`dasmeta/grafana/onpremise` module resolves exactly to version `1.32.1`.

**Acceptance Scenarios**:

1. **Given** the wrapper currently pins `1.32.0`, **when** the dependency
   update is applied, **then** `module.this` pins `1.32.1`.
2. **Given** an existing wrapper consumer, **when** it upgrades to the next
   wrapper release, **then** no new AWS-wrapper input, output, provider, or
   resource is required.

### Edge Cases

- The target release must already be published before the wrapper pin changes.
- Documentation must describe the exact dependency version so consumer review
  is reproducible.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `main.tf` MUST reference `dasmeta/grafana/onpremise` version
  `1.32.1`.
- **FR-002**: The change MUST preserve all wrapper inputs, outputs, resources,
  and provider constraints.
- **FR-003**: README dependency references MUST match the source pin.
- **FR-004**: The wrapper MUST be released before a consumer module pin is
  changed.

### Key Entities

- **AWS Grafana wrapper**: Opinionated AWS-specific wrapper that forwards its
  existing interface to the on-premise Grafana module.
- **On-premise Grafana module v1.32.1**: Published child dependency containing
  the kube-state-metrics annotation-scrape fix.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The only Terraform source change is the child module version
  from `1.32.0` to `1.32.1`.
- **SC-002**: `terraform init -backend=false` resolves on-premise `1.32.1`.
- **SC-003**: Formatting and Terraform validation pass.

## Assumptions

- Version `1.32.1` is published and resolves from the Terraform Registry.
- This is a compatible child-module patch update.
- Publishing the wrapper and updating consumer IaC are separate follow-up steps.
