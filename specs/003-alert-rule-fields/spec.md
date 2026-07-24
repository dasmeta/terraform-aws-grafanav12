# Feature Specification: Alert Rule Field Preservation

**Feature Branch**: `003-alert-rule-fields`  
**Created**: 2026-07-24  
**Status**: Draft  
**Input**: User description: "Preserve Grafana alert rule fields when the AWS wrapper forwards alerts to the onpremise module"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Configure Loki alert rules through the AWS wrapper (Priority: P1)

Operators using `dasmeta/grafanav12/aws` can define custom Grafana alert rules that use Loki-specific datasource metadata and custom alert evaluation settings, and those fields remain accepted by the wrapper before the configuration is forwarded to `dasmeta/grafana/onpremise`.

**Why this priority**: The AWS wrapper already delegates alert rendering to the onpremise module. If wrapper input typing omits supported downstream fields, valid consumer configuration can be rejected or normalized incorrectly before reaching the nested module.

**Independent Test**: A Terraform fixture passes an alert rule with `datasource_type = "loki"`, `interval_ms`, `pending_period`, and `condition`; `terraform validate` accepts the module input.

**Acceptance Scenarios**:

1. **Given** a custom alert rule using a Loki datasource, **When** the AWS module is validated, **Then** `datasource_type = "loki"` is accepted by the wrapper schema.
2. **Given** a custom alert rule with explicit evaluation timing, **When** the AWS module is validated, **Then** `interval_ms` and `pending_period` are accepted by the wrapper schema.
3. **Given** a custom alert rule with a full math condition override, **When** the AWS module is validated, **Then** `condition` is accepted by the wrapper schema.

### User Story 2 - Tune global disk-capacity alerts through the AWS wrapper (Priority: P2)

Operators can pass the onpremise module's `alerts.disk_capacity` configuration through the AWS wrapper without losing datasource, threshold, timing, label, or annotation settings.

**Why this priority**: The nested module supports the global PVC disk-capacity alert, and the AWS wrapper should not hide supported alert tuning options from AWS consumers.

**Independent Test**: A Terraform fixture passes `alerts.disk_capacity` with VictoriaMetrics datasource settings and validation accepts the input.

**Acceptance Scenarios**:

1. **Given** VictoriaMetrics is enabled, **When** an operator sets `alerts.disk_capacity.datasource = "victoriametrics"`, **Then** the AWS wrapper accepts the setting.
2. **Given** an operator changes disk-capacity alert threshold and pending period, **When** the AWS module is validated, **Then** the wrapper accepts those fields.

### Edge Cases

- Existing consumers that omit the new optional fields continue to use current defaults.
- Prometheus-compatible datasource users can keep `datasource_type = "prometheus"` or omit it.
- Loki alert rules must explicitly set `datasource_type = "loki"` because their expressions are LogQL, not PromQL.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The AWS wrapper MUST accept `alerts.rules[*].datasource_type`.
- **FR-002**: The AWS wrapper MUST accept `alerts.rules[*].interval_ms`.
- **FR-003**: The AWS wrapper MUST accept `alerts.rules[*].pending_period`.
- **FR-004**: The AWS wrapper MUST accept `alerts.rules[*].condition`.
- **FR-005**: The AWS wrapper MUST accept `alerts.disk_capacity` fields supported by `dasmeta/grafana/onpremise` `1.28.0`.
- **FR-006**: Existing alert configurations that do not set the new optional fields MUST remain valid.
- **FR-007**: Documentation MUST expose the expanded alert input schema.

### Key Entities

- **Alert Rule**: Custom Grafana alert rule forwarded through the AWS wrapper to the onpremise module.
- **Disk Capacity Alert**: Global PVC usage alert configuration supported by the nested onpremise module.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `terraform validate` succeeds for a fixture containing a Loki custom rule with `datasource_type`, `interval_ms`, `pending_period`, and `condition`.
- **SC-002**: `terraform validate` succeeds for a fixture containing a `disk_capacity` alert configuration.
- **SC-003**: The generated README input table includes the newly exposed alert fields.

## Assumptions

- The nested onpremise module version remains `1.28.0`.
- `datasource_type = "prometheus"` remains the backward-compatible default for metric alert rules.
- VictoriaMetrics uses Grafana's Prometheus datasource plugin type, so VictoriaMetrics alert rules should keep `datasource_type = "prometheus"` unless they are actually Loki rules.
