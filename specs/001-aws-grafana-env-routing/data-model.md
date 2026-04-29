## Data Model

This feature is configuration-centric. "Entities" below describe Terraform configuration objects and their relationships rather than persisted runtime records.

### 1) WrappedModuleVersion
- **Description**: Version pin of the wrapped `dasmeta/grafana/onpremise` module in AWS wrapper `main.tf`.
- **Fields**:
  - `source` (string, required): expected `dasmeta/grafana/onpremise`.
  - `version` (string, required): latest compatible version providing same-cluster env routing parity.
- **Validation Rules**:
  - Must reference same module source as before.
  - Must not introduce breaking input changes in wrapper pass-through usage.
- **Relationships**:
  - Enables behavior consumed by `RoutingExampleConfiguration`.

### 2) RoutingExampleConfiguration
- **Description**: Dedicated AWS test scenario inputs demonstrating namespace/environment alert routing.
- **Fields**:
  - `application_dashboard[].rows[].alerts.namespaces` (list(string)): environments/namespaces to generate service alerts.
  - `alerts.rules[].labels.env` (string, optional): explicit environment label for rule-level routing.
  - `alerts.contact_points.slack[]` (list(object)): per-environment and fallback destinations.
  - `alerts.notifications.contact_point` (string): fallback destination for unmatched alerts.
  - `alerts.notifications.policies[]` (list(object)): matcher-based routing policies.
- **Validation Rules**:
  - At least one policy matcher uses `label = "env"`.
  - Fallback `contact_point` remains set for unmatched environments.
  - Scenario validates with `terraform init` and `terraform validate`.
- **Relationships**:
  - Uses `EnvironmentMatcherPolicy` entries to route alerts.

### 3) EnvironmentMatcherPolicy
- **Description**: Notification policy rule mapping `env` label values to contact points.
- **Fields**:
  - `contact_point` (string, required)
  - `matchers[]` (list(object), required)
    - `label` (string, required; this feature expects `env`)
    - `match` (string, required; typically `=`)
    - `value` (string, required; e.g., `dev`, `stage`, `prod`)
- **Validation Rules**:
  - Each environment-specific policy has a distinct matcher `value`.
  - Policies are compatible with existing onprem notification schema.
- **Relationships**:
  - Contained by `RoutingExampleConfiguration.alerts.notifications.policies`.

## State Transitions

1. **Pre-upgrade state**: AWS wrapper references older onprem module version.
2. **Upgrade state**: Wrapper version pin updated to latest compatible release.
3. **Validation state**: Dedicated test scenario demonstrates matcher-based env routing with fallback.
4. **Documentation state**: README points users to upgraded behavior and dedicated test usage.
