# Implementation Plan: Ignore Public ACLs Support

**Branch**: `002-ignore-public-acls` | **Date**: 2026-05-06 | **Spec**: `/Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12/specs/002-ignore-public-acls/spec.md`
**Input**: Feature specification from `/Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12/specs/002-ignore-public-acls/spec.md`

## Summary

Extend the Terraform module interface so consumers can set `ignore_public_acls` for the module-managed Loki and Tempo S3 buckets, keep the inputs optional with secure defaults, and document the new fields in README and existing test examples.

## Technical Context

**Language/Version**: HCL (Terraform ~> 1.3)  
**Primary Dependencies**: Terraform providers `aws`, `grafana`, `helm`, `deepmerge`; Terraform modules `dasmeta/grafana/onpremise`, `dasmeta/s3/aws`, `dasmeta/iam/aws`  
**Storage**: AWS S3 buckets managed through child modules for Loki and Tempo  
**Testing**: `terraform fmt -check`, `terraform validate`, and example-folder validation in `tests/`  
**Target Platform**: AWS EKS environments using this Grafana wrapper module  
**Project Type**: Terraform module  
**Performance Goals**: No runtime behavior or performance regressions; input expansion only  
**Constraints**: Backward-compatible interface change, no broad refactor of the existing object layout, no change to unrelated bucket security flags  
**Scale/Scope**: Three root files (`main.tf`, `variables.tf`, `README.md`), existing example files in `tests/`, and Speckit documentation for this feature

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Constitution file at `/Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12/.specify/memory/constitution.md` is still the default placeholder template and does not define project-specific gates.

Gate status (pre-design): PASS.

Re-check status (post-design): PASS. The change is a minimal, backward-compatible module interface extension and stays within repository scope.

## Project Structure

### Documentation (this feature)

```text
specs/002-ignore-public-acls/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── s3-public-access-inputs.md
└── tasks.md
```

### Source Code (repository root)

```text
main.tf
variables.tf
README.md
tests/
├── base/
│   └── 1-example.tf
└── base-with-victoria-metrics/
    └── 1-example.tf
```

**Structure Decision**: Reuse the existing root module structure and existing example scenarios. This feature does not justify a new scenario directory because it only expands current bucket input support.

## Complexity Tracking

No constitutional violations or extra architectural complexity requiring justification.
