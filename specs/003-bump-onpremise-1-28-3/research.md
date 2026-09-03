# Research: Bump Grafana On-Premise Dependency

## Decision: use the published v1.28.3 child-module release

- **Rationale**: v1.28.3 is the published patch release containing the corrected memory working-set metric behavior. The wrapper currently references v1.28.0.
- **Alternatives considered**:
  - Keep v1.28.0: does not deliver the incident correction.
  - Point a consumer directly to the on-premise module: would replace the AWS wrapper and break its AWS-specific configuration boundary.
  - Set a consumer wrapper pin to v1.28.3: invalid because wrapper and child module have independent version series.

## Decision: no wrapper interface or test-fixture change

- **Rationale**: The version update preserves the wrapper contract. The child module owns the corrected alert implementation.
- **Alternatives considered**: Duplicating child-module tests or editing consumer YAML would widen this small release without improving dependency resolution coverage.
