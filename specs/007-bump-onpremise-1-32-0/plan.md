# Implementation Plan: Bump On-Premise Grafana Dependency to 1.32.0

**Branch**: `feat/bump-onpremise-grafana-v1320` | **Date**: 2026-10-15 | **Spec**: [spec.md](spec.md)

## Summary

Change the AWS wrapper's nested `dasmeta/grafana/onpremise` dependency from `1.30.0` to released `1.32.0`. This preserves the existing opinionated AWS wrapper interface and exposes the upstream compatibility fix through the next wrapper release.

## Repository and Governance Assessment

- Current wrapper: `main.tf` wraps `dasmeta/grafana/onpremise` `1.30.0`; `versions.tf` owns existing provider constraints.
- Affected scope: root `main.tf`, README dependency references, and this Speckit evidence package. No submodule, variables, outputs, or test fixture change is needed.
- Wrapper preservation: pass. No public input is added, removed, or regrouped; optional attributes and defaults are unchanged.
- Breaking change: none. Interface widening: none.
- Modern-capabilities classification: not applicable; the request introduces no provider feature or net-new module ability.
- New-module sourcing and fallback template checks: not applicable; this is an existing wrapper dependency pin, not a new module.
- Shared governance: `terraform-module-developer` standards and planning checklist were used from the constitution repository.
- Module-change gate: expected to pass because `spec.md`, `plan.md`, and `tasks.md` are included with the source update.

## File Changes

1. Update `main.tf` child module version to `1.32.0`.
2. Update README module-version documentation and the wrapper dependency sentence.
3. Add no provider, interface, or test-fixture changes.

## Validation

1. Confirm the exact source/version pair in `main.tf`.
2. Run `terraform fmt -check -recursive`.
3. Run `terraform init -backend=false` and `terraform validate`.
4. Run the repository pre-commit suite if available and inspect `git diff --check`.

## Release Handoff

Publish a new patch release of `dasmeta/grafanav12/aws`. Only after it is published should consumer IaC change its wrapper pin and run a Terraform plan.
