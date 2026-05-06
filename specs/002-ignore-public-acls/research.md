# Research: Ignore Public ACLs Support

## Decision 1: Expose the new inputs at the existing Loki and Tempo bucket configuration points

- **Decision**: Add `ignore_public_acls` under `loki_stack.send_logs_s3` and `tempo`.
- **Rationale**: Those are the current consumer-facing locations for configuring the module-managed Loki and Tempo S3 buckets, so the new capability fits the established interface shape without introducing a new wrapper object.
- **Alternatives considered**:
  - Add a new shared top-level S3 settings object: rejected because it would widen scope and break the existing opinionated layout.
  - Hide the feature behind `extra_configs`: rejected because this setting belongs to the managed S3 bucket module, not to Helm chart values.

## Decision 2: Use secure defaults instead of nullable pass-through

- **Decision**: Default both new inputs to `true`.
- **Rationale**: `ignore_public_acls` is part of S3 public-access-block hardening, and a secure default preserves the module's opinionated security posture while keeping the fields optional.
- **Alternatives considered**:
  - Default to `false`: rejected because it weakens the default bucket posture.
  - Use `null` and rely on downstream defaults: rejected because this repository should not depend on undocumented child-module behavior when a clear secure default is available.

## Decision 3: Reuse existing test examples instead of creating a new scenario

- **Decision**: Update `tests/base/1-example.tf` and `tests/base-with-victoria-metrics/1-example.tf` to demonstrate the new inputs.
- **Rationale**: The feature is small and configuration-only, so existing scenarios already cover the relevant Loki and Tempo paths without adding maintenance overhead.
- **Alternatives considered**:
  - Create a dedicated new test scenario: rejected because it would add scaffolding disproportionate to the size of the change.
