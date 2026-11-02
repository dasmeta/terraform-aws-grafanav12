# Implementation Plan: AWS Grafana Wrapper On-Premise 1.33.1 Compatibility

**Branch**: `008-onpremise-1-33-1` | **Date**: 2026-11-02 | **Spec**: [spec.md](spec.md)

## Summary

Update the AWS wrapper's two on-premise Grafana references from `1.33.0` to `1.33.1`. Relax the outer `application_dashboard` input to `any`, document its expected structure, and add a root-module regression test for heterogeneous rows.

## Repository and Governance Assessment

- Current wrapper: `main.tf` wraps on-premise Grafana `1.33.0`; `versions.tf` owns provider constraints.
- Wrapper preservation: pass. The existing direct pass-through remains; its type is relaxed only to prevent Terraform coercion of block-specific rows.
- Compatibility: preserve the former wrapper-level defaults in an input-normalization local before forwarding values.
- Modern capabilities: not applicable; no provider feature or new AWS capability is introduced.
- New-module sourcing: not applicable; this is an existing opinionated wrapper.
- Shared governance: `terraform-module-developer` standards and planning checklist were consulted.
- Module-change gate: expected to pass with this `spec.md`, `plan.md`, and `tasks.md` package.

## File Changes

1. Pin both `dasmeta/grafana/onpremise` references in `main.tf` to `1.33.1`.
2. Relax and document `application_dashboard` in `variables.tf`, then normalize former defaults in locals before forwarding it.
3. Update README version references and compatibility guidance.
4. Add `tests/heterogeneous_application_dashboard.tftest.hcl` with a mixed-row root-wrapper regression case.

## Validation

1. Run the mixed-row test before the type change to prove the former failure.
2. Run `terraform fmt -check -recursive`, `terraform init -backend=false`, `terraform validate`, and `terraform test`.
3. Run repository pre-commit checks and inspect `git diff --check`.

## Release Handoff

Publish the next `dasmeta/grafanav12/aws` version after this PR merges. Only then may consumer configurations pin that version.
