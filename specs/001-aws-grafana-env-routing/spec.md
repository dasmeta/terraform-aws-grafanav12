# Feature Specification: AWS Grafana Env Routing Parity

**Feature Branch**: `001-aws-grafana-env-routing`  
**Created**: 2026-04-27  
**Status**: Draft  
**Input**: User description: "in dasmeta/terraform-aws-grafanav12 repo now lets have the depenency onpremise grafana module version upgraded to latest one in @dasmeta/terraform-aws-grafanav12/main.tf:2-4 , so that in this aws specific grafana stack setup we get support for same multi environemt/namespace service alerts routing, create a separate example/test in dasmeta/terraform-aws-grafanav12/tests similar to one we had created for terraform-onpremise-grafana in dasmeta/terraform-onpremise-grafana/tests/multi-environment-alert-routing, have corresponding docs in readme files"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Upgrade dependency for routing parity (Priority: P1)

As an AWS Grafana module operator, I can consume the latest onpremise Grafana module version so same-cluster namespace-to-environment alert routing behavior is available in the AWS wrapper module.

**Why this priority**: Without dependency parity, AWS users cannot use the newly delivered same-cluster environment routing behavior.

**Independent Test**: Update only the wrapped onprem module version in AWS module configuration and confirm a validation example can use namespace/environment matcher routing behavior.

**Acceptance Scenarios**:

1. **Given** AWS wrapper module references the previous onprem module version, **When** the dependency is upgraded to the latest compatible version, **Then** the AWS wrapper exposes same-cluster environment routing capability without requiring additional breaking input changes.
2. **Given** upgraded dependency, **When** a same-cluster routing configuration is applied in an AWS test example, **Then** validation confirms configuration compatibility.

---

### User Story 2 - Provide dedicated AWS routing example/test (Priority: P2)

As an engineer validating module behavior, I can run a dedicated AWS test/example for namespace/environment alert routing, separate from existing base tests.

**Why this priority**: A focused example reduces ambiguity and prevents regressions in existing baseline tests.

**Independent Test**: Run Terraform init/validate in the new dedicated test/example folder and confirm it covers environment label matcher routing with fallback.

**Acceptance Scenarios**:

1. **Given** a dedicated AWS routing test/example, **When** Terraform validation is executed, **Then** configuration is valid and demonstrates same-cluster matcher-based routing behavior.

---

### User Story 3 - Document upgrade and usage path (Priority: P3)

As a module consumer, I can read concise documentation that explains dependency upgrade intent, how to use the dedicated routing example, and how to configure matcher-based environment routing in AWS module context.

**Why this priority**: Correct adoption depends on clear guidance, especially for module version and test/example usage.

**Independent Test**: Follow README instructions to locate the new example and configure namespace/environment routing without inspecting implementation internals.

**Acceptance Scenarios**:

1. **Given** updated README documentation, **When** a user follows the instructions, **Then** they can identify the upgraded dependency behavior and apply matcher-based same-cluster routing configuration in AWS module usage.

---

### Edge Cases

- What happens when existing AWS consumers pin older versions and do not upgrade?
- How does the example behave when namespace labels do not match any environment policy matcher?
- How is fallback routing documented for unmatched environment identity in the AWS example?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The AWS Grafana wrapper module MUST reference the latest compatible onpremise Grafana module version required for same-cluster namespace/environment routing support.
- **FR-002**: The AWS module MUST maintain pass-through compatibility for alert routing configuration using existing matcher-based notification policies.
- **FR-003**: A new dedicated AWS test/example scenario MUST be added for same-cluster multi-environment namespace routing, separate from existing baseline tests.
- **FR-004**: The dedicated AWS test/example MUST demonstrate environment matcher routing and unmatched-environment fallback behavior.
- **FR-005**: README documentation MUST describe the dependency upgrade purpose and how to use the dedicated routing example.
- **FR-006**: README documentation MUST include same-cluster matcher-based routing configuration guidance in AWS module context.
- **FR-007**: Existing baseline test scenarios MUST remain intact and not be repurposed for the new routing example.

### Key Entities *(include if feature involves data)*

- **Wrapped Module Version**: The onprem module version consumed by AWS wrapper and used to inherit routing capabilities.
- **Routing Example Configuration**: Example alert rules, labels, contact points, and notification policies that demonstrate namespace/environment routing behavior.
- **Environment Matcher Policy**: Notification policy matcher rules mapping `env` label values to environment-specific contact points.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: AWS module dependency reference is updated to the latest required onprem version in a single release.
- **SC-002**: Dedicated AWS routing test/example validates successfully with Terraform init/validate.
- **SC-003**: 100% of routing-related README guidance needed to run the dedicated example is present in the module documentation.
- **SC-004**: Existing baseline test examples remain unchanged in purpose and continue to validate successfully.

## Assumptions

- The latest onprem module version is compatible with current AWS wrapper interface for alert configurations.
- Same-cluster namespace-to-environment routing remains in scope; multi-cluster central Grafana topology is out of scope for this feature.
- Existing CI/local validation flow for module tests continues to use Terraform commands.
- Consumers use matcher-based `notifications.policies.matchers` for environment routing, with fallback contact point behavior for unmatched labels.
