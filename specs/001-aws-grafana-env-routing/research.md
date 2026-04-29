## Phase 0 Research

### Decision 1: Keep matcher-based routing model (no new wrapper field)
- **Decision**: Use existing `alerts.notifications.policies[*].matchers` with `env` label matching and default `contact_point` fallback.
- **Rationale**: The wrapped onprem module already supports matcher policies, and this preserves interface parity without introducing duplicate routing abstractions.
- **Alternatives considered**:
  - Add dedicated `environment_routing` input wrapper (rejected: duplicates matcher functionality and increases complexity).

### Decision 2: Validate parity via dedicated AWS test scenario
- **Decision**: Add `tests/multi-environment-alert-routing` with isolated `0-setup.tf`, `1-example.tf`, and scenario README.
- **Rationale**: Keeps `tests/base` stable while providing focused, reproducible validation for environment-specific routing and fallback behavior.
- **Alternatives considered**:
  - Extend `tests/base` directly (rejected: weakens baseline test intent and mixes concerns).

### Decision 3: Dependency upgrade strategy for wrapped onprem module
- **Decision**: Pin AWS wrapper `module "this"` source version to the latest compatible onprem release used for env-routing support.
- **Rationale**: Ensures consumers get routing capabilities through normal module upgrade path while keeping root input schema backward compatible.
- **Alternatives considered**:
  - Leave current pin and document manual workarounds (rejected: does not satisfy parity requirement).

### Decision 4: Documentation placement and scope
- **Decision**: Update root `README.md` with a concise usage section covering (1) intent of dependency upgrade, (2) dedicated test location, and (3) matcher/fallback routing example in AWS context.
- **Rationale**: Central README is where module users discover behavior and examples; adds minimal documentation overhead with high discoverability.
- **Alternatives considered**:
  - Document only inside test README (rejected: users may miss the feature at module entry point).
