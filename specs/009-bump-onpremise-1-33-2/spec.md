# Feature Specification: AWS Grafana Wrapper On-Premise 1.33.2

**Feature Branch**: `009-bump-onpremise-1-33-2`
**Created**: 2026-11-03
**Status**: Approved
**Input**: Update the AWS Grafana wrapper to consume released on-premise Grafana `1.33.2`.

## Requirements

- Both `dasmeta/grafana/onpremise` references in `main.tf` use `1.33.2`.
- The wrapper interface, AWS resources, and child-module inputs remain unchanged.
- Terraform resolves the released Registry version and existing repository checks pass.

## Compatibility

This is a backward-compatible dependency bump. It introduces no provider, AWS,
or consumer-interface change.
