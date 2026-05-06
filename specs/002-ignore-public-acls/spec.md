# Feature Specification: Ignore Public ACLs Support

**Feature Branch**: `002-ignore-public-acls`  
**Created**: 2026-05-06  
**Status**: Draft  
**Input**: User description: "Add ignore_public_acls support for loki and tempo in grafana"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Configure Loki bucket ACL handling (Priority: P1)

As a module consumer deploying Loki storage, I can configure `ignore_public_acls` for the Loki S3 bucket through the module interface.

**Why this priority**: Loki already manages an internal S3 bucket in this module, and the ticket explicitly requires adding `ignore_public_acls` support there.

**Independent Test**: Set `loki_stack.send_logs_s3.ignore_public_acls` in an example configuration and validate that Terraform accepts the input and wires it into the module-managed S3 bucket settings.

**Acceptance Scenarios**:

1. **Given** Loki is enabled and uses the module-managed S3 bucket, **When** a consumer sets `loki_stack.send_logs_s3.ignore_public_acls`, **Then** the module applies that value to the Loki bucket configuration.
2. **Given** Loki is enabled and the consumer does not set the new field, **When** Terraform evaluates the module, **Then** the module keeps a secure default behavior without requiring any new mandatory input.

---

### User Story 2 - Configure Tempo bucket ACL handling (Priority: P2)

As a module consumer deploying Tempo storage, I can configure `ignore_public_acls` for the Tempo S3 bucket through the module interface.

**Why this priority**: Tempo uses a separate module-managed S3 bucket and must receive the same capability to keep behavior consistent.

**Independent Test**: Set `tempo.ignore_public_acls` in an example configuration and validate that Terraform accepts the input and wires it into the module-managed Tempo bucket settings.

**Acceptance Scenarios**:

1. **Given** Tempo is enabled and uses the module-managed S3 bucket, **When** a consumer sets `tempo.ignore_public_acls`, **Then** the module applies that value to the Tempo bucket configuration.
2. **Given** Tempo is enabled and the consumer does not set the new field, **When** Terraform evaluates the module, **Then** the module keeps a secure default behavior without requiring any new mandatory input.

---

### User Story 3 - Discover and validate the new inputs (Priority: P3)

As a module consumer, I can discover the new `ignore_public_acls` inputs in examples and README documentation and verify them with existing Terraform validation flows.

**Why this priority**: The feature is not useful if consumers cannot find the correct input locations for Loki and Tempo.

**Independent Test**: Follow the README/example updates and run Terraform validation in the existing test scenarios without consulting implementation internals.

**Acceptance Scenarios**:

1. **Given** the module README and examples are updated, **When** a consumer looks for S3 public-access-block settings, **Then** they can identify where to set `ignore_public_acls` for Loki and Tempo.
2. **Given** the updated example scenarios, **When** Terraform validation is run, **Then** the module accepts the new inputs without breaking existing test structure.

---

### Edge Cases

- What happens when only Loki is enabled and Tempo remains disabled?
- What happens when only Tempo is enabled and Loki remains disabled?
- How does the module behave when consumers omit the new fields entirely?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The module MUST expose `loki_stack.send_logs_s3.ignore_public_acls` as an optional consumer input for the Loki-managed S3 bucket.
- **FR-002**: The module MUST expose `tempo.ignore_public_acls` as an optional consumer input for the Tempo-managed S3 bucket.
- **FR-003**: The module MUST pass the configured Loki value to the `loki_bucket` module's `ignore_public_acls` setting.
- **FR-004**: The module MUST pass the configured Tempo value to the `tempo_bucket` module's `ignore_public_acls` setting.
- **FR-005**: The new inputs MUST preserve backward compatibility by remaining optional and by not requiring changes to existing consumers.
- **FR-006**: README documentation MUST describe where consumers set `ignore_public_acls` for Loki and Tempo.
- **FR-007**: At least one existing Terraform example/test scenario for Loki and one for Tempo MUST demonstrate the new inputs.

### Key Entities *(include if feature involves data)*

- **Loki S3 Bucket Settings**: Consumer-provided configuration under `loki_stack.send_logs_s3` that controls the module-managed S3 bucket used by Loki storage.
- **Tempo S3 Bucket Settings**: Consumer-provided configuration under `tempo` that controls the module-managed S3 bucket used by Tempo storage.
- **Public Access Block Behavior**: S3 bucket-level `ignore_public_acls` configuration passed through this module into the underlying S3 bucket module.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Terraform accepts `loki_stack.send_logs_s3.ignore_public_acls` and `tempo.ignore_public_acls` in the module type definitions with no new required inputs.
- **SC-002**: The root module passes `ignore_public_acls` into both `loki_bucket` and `tempo_bucket`.
- **SC-003**: Updated Terraform example scenarios validate successfully after adding the new inputs.
- **SC-004**: README documentation clearly identifies both input locations for consumers.

## Assumptions

- The underlying `dasmeta/s3/aws` module version already supports an `ignore_public_acls` input.
- Keeping a secure default is preferable to introducing a nullable pass-through that would rely on undocumented downstream behavior.
- Existing test scenarios are the correct place to demonstrate the new inputs; no new standalone scenario is required for this small interface extension.
