# Implementation Plan: Alert Rule Field Preservation

**Branch**: `003-alert-rule-fields` | **Date**: 2026-07-24 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `/specs/003-alert-rule-fields/spec.md`

## Summary

Expand the `alerts` variable schema in the AWS wrapper so it mirrors alert rule and disk-capacity fields already supported by `dasmeta/grafana/onpremise` `1.28.0`. Add fixture coverage with VictoriaMetrics enabled and a Loki custom alert rule to prove wrapper validation accepts the fields.

## Technical Context

**Language/Version**: Terraform `~> 1.3`  
**Primary Dependencies**: `dasmeta/grafana/onpremise` `1.28.0`, Grafana provider `~> 4.0`  
**Storage**: N/A  
**Testing**: `terraform fmt -check`, `terraform validate` on module root and fixture directories  
**Target Platform**: Terraform module for AWS EKS-hosted Grafana stack  
**Project Type**: Terraform module  
**Performance Goals**: No runtime behavior change; input schema expansion only  
**Constraints**: Backward-compatible optional inputs only  
**Scale/Scope**: One wrapper variable contract and one fixture/example update

## Constitution Check

The project constitution currently contains placeholder principles only. No additional gates are defined beyond preserving backward compatibility, documenting inputs, and validating Terraform syntax.

## Project Structure

### Documentation (this feature)

```text
specs/003-alert-rule-fields/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── alert-input-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
variables.tf
README.md
tests/base-with-victoria-metrics/1-example.tf
```

**Structure Decision**: Keep the change in the module wrapper contract and reuse the VictoriaMetrics fixture to validate both metric and Loki alert-rule inputs.

## Complexity Tracking

No constitution violations or additional abstractions.
