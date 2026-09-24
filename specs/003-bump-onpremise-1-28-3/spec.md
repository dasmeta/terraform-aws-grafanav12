# Feature Specification: Bump Grafana On-Premise Dependency

**Feature Branch**: `003-bump-onpremise-1-28-3`  
**Created**: 2026-09-03  
**Status**: Ready for implementation  
**Input**: Update the AWS Grafana wrapper so downstream consumers receive the v1.28.3 memory working-set alert correction.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Consume the corrected alert behavior (Priority: P1)

Platform operators can select a released AWS Grafana wrapper version that incorporates the underlying Grafana module's v1.28.3 memory alert and dashboard behavior.

**Why this priority**: The correction prevents alerts based on reclaimable container cache from being treated as pod memory overload.

**Independent Test**: Inspect the wrapper source and confirm its nested Grafana module reference resolves to v1.28.3.

**Acceptance Scenarios**:

1. **Given** the wrapper currently references v1.28.0, **When** the dependency update is applied, **Then** it references v1.28.3.
2. **Given** a consumer selects the next wrapper release, **When** Terraform initializes the wrapper, **Then** the wrapper resolves the published v1.28.3 dependency.

### Edge Cases

- The requested v1.28.3 dependency version must exist in the upstream registry before release.
- No wrapper input, output, provider, or resource behavior outside the nested dependency version may change.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The wrapper MUST reference `dasmeta/grafana/onpremise` version `1.28.3`.
- **FR-002**: The update MUST preserve the wrapper's existing public interface and AWS-specific configuration.
- **FR-003**: The change MUST be limited to the nested module version and its validation evidence.
- **FR-004**: The wrapper MUST be released with a new wrapper version before a consumer dependency pin is changed.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The sole Terraform source diff changes the nested module version from `1.28.0` to `1.28.3`.
- **SC-002**: `terraform fmt -check` and `terraform validate` succeed for the wrapper, subject to available provider support on the execution host.
- **SC-003**: The next wrapper release can be selected by downstream consumers without changing their input configuration.

## Assumptions

- The upstream v1.28.3 release contains the requested memory working-set correction.
- This is a patch-compatible dependency update with no wrapper interface change.
- Publishing the wrapper release and updating consumer repositories are separate follow-up steps.
