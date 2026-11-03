# Feature Specification: AWS Grafana Wrapper On-Premise 1.33.2

**Feature Branch**: `009-bump-onpremise-1-33-2`
**Created**: 2026-11-03
**Status**: Approved
**Input**: Update the AWS Grafana wrapper to consume released on-premise Grafana `1.33.2`.

## Requirements

- Both `dasmeta/grafana/onpremise` references in `main.tf` use `1.33.2`.
- The existing `tempo` object accepts and forwards optional
  `service_graph_dimensions` labels supported by `1.33.2`.
- Existing wrapper inputs, AWS resources, and child-module inputs remain unchanged.
- Terraform resolves the released Registry version and existing repository checks pass.

## Compatibility

This is a backward-compatible dependency bump. The existing `tempo` object
gains one optional field with an empty-list default; it introduces no provider
or AWS-resource change.
