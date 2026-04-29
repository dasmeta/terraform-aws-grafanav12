# Implementation Plan: AWS Grafana Env Routing Parity

**Branch**: `001-aws-grafana-env-routing` | **Date**: 2026-04-27 | **Spec**: `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/specs/001-aws-grafana-env-routing/spec.md`
**Input**: Feature specification from `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/specs/001-aws-grafana-env-routing/spec.md`

## Summary

Upgrade the wrapped `dasmeta/grafana/onpremise` dependency in the AWS module to the latest compatible version, then add a dedicated AWS test scenario and README guidance that demonstrates same-cluster namespace/environment alert routing via existing `alerts.notifications.policies[*].matchers` with an explicit fallback contact point.

## Technical Context

**Language/Version**: HCL (Terraform ~> 1.3)  
**Primary Dependencies**: Terraform providers `aws`, `grafana`, `helm`, `deepmerge`; Terraform module `dasmeta/grafana/onpremise`  
**Storage**: N/A (configuration module; no feature-local data store)  
**Testing**: `terraform init` and `terraform validate` for the dedicated scenario in `tests/`  
**Target Platform**: AWS EKS environments using Grafana stack deployment  
**Project Type**: Terraform module (AWS wrapper around onprem Grafana module)  
**Performance Goals**: No runtime performance changes; preserve current plan/apply behavior  
**Constraints**: Keep base tests unchanged; same-cluster multi-namespace/environment routing only; maintain backward-compatible input shape  
**Scale/Scope**: Single module version bump, one dedicated test/example folder, and README updates

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Constitution file at `/Users/tmuradyan/projects/dasmeta/terraform-aws-grafanav12/.specify/memory/constitution.md` is a placeholder template with no enforceable project principles defined yet.

Gate status (pre-design): PASS with no explicit constitutional constraints to violate.

Re-check status (post-design): PASS; planned design remains minimal, backward compatible, and within module scope.

## Project Structure

### Documentation (this feature)

```text
specs/001-aws-grafana-env-routing/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── routing-input-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
main.tf
README.md
tests/
├── base/
├── base-with-victoria-metrics/
├── gitlab-sso/
└── multi-environment-alert-routing/   # new dedicated example/test
    ├── 0-setup.tf
    ├── 1-example.tf
    └── README.md
```

**Structure Decision**: Keep existing single-module structure; add one isolated test/example under `tests/` and update top-level module documentation.

## Complexity Tracking

No constitution violations or added architectural complexity requiring justification.
