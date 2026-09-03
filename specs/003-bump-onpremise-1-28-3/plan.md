# Implementation Plan: Bump Grafana On-Premise Dependency

**Branch**: `003-bump-onpremise-1-28-3` | **Date**: 2026-09-03 | **Spec**: [spec.md](spec.md)

## Summary

Update the AWS-specific Grafana wrapper's nested `dasmeta/grafana/onpremise` dependency from v1.28.0 to v1.28.3. This preserves the existing wrapper interface while allowing a subsequent wrapper release to carry the corrected memory working-set alert and dashboard behavior to consumers.

## Technical Context

**Language/Version**: Terraform `~> 1.3` (local CLI: v1.15.0)  
**Primary Dependencies**: `dasmeta/grafana/onpremise`, `isometry/deepmerge`, AWS, Helm, and Grafana providers  
**Storage**: N/A  
**Testing**: `terraform fmt -check`; `terraform init -backend=false` and `terraform validate` where the locally installed provider supports the host architecture  
**Target Platform**: Terraform Registry module consumed from AWS-backed infrastructure roots  
**Project Type**: Terraform module wrapper  
**Performance Goals**: No performance change; retain current wrapper initialization behavior  
**Constraints**: No public-interface, provider, resource, test-fixture, or consumer YAML changes; only the nested module version may change  
**Scale/Scope**: One `module "this"` dependency reference in `main.tf`

## Constitution Check

The repository's `.specify` constitution is an unfilled template and supplies no project-specific gates. Shared governance is sourced from the Terraform module developer standard.

- Wrapper preservation: pass. The existing AWS wrapper remains opinionated and no input/output shape changes.
- Breaking change: none expected; v1.28.3 is a patch update of an existing child dependency.
- Interface widening: none.
- Modern capabilities: not applicable; this introduces no new capability or provider feature.
- Speckit evidence: this feature contains `spec.md`, this `plan.md`, and will contain `tasks.md` before source edits.
- Downstream module-change gate: expected to pass once the Speckit evidence and source update are committed together.

## Repository Assessment

- Current module state: `main.tf` wraps `dasmeta/grafana/onpremise` v1.28.0 while retaining AWS-specific IAM, storage, and provider configuration.
- Related scope: no submodule or consumer repository changes are required.
- Existing tests: the repository has integration-style Terraform cases under `tests/`; no native `.tftest.hcl` suite covers this version pin.
- Baseline gaps: existing test layout does not follow the current native Terraform test convention, but restructuring it is outside this bounded upgrade.
- Provider layout: `versions.tf` contains provider constraints; it is unchanged.

## Project Structure

```text
main.tf                                      # Nested on-premise Grafana module dependency
versions.tf                                  # Existing Terraform/provider constraints; unchanged
tests/                                       # Existing integration-style scenarios; unchanged
specs/003-bump-onpremise-1-28-3/             # Change evidence and validation instructions
```

**Structure Decision**: Update the existing nested-module reference in the repository root; no interface or file-layout change is needed.

## Proposed File Changes

1. Change `main.tf` so `module "this"` uses `dasmeta/grafana/onpremise` v1.28.3.
2. Retain no fixture changes because this is a dependency-resolution upgrade and the underlying module has its own tested alert behavior.
3. Validate formatting and Terraform configuration; record any host-provider limitation accurately.

## Release and Consumer Follow-Up

Publish this wrapper as the next compatible wrapper release (for example, v1.1.9). Only after the wrapper is published should Ben Energy change both Grafana stack YAML pins from v1.1.8 to that new wrapper version.
