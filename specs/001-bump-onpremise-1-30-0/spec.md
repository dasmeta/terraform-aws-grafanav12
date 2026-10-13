# Bump on-premise Grafana to v1.30.0

## Goal

Update the AWS Grafana wrapper to consume the released `dasmeta/grafana/onpremise` v1.30.0 module.

## Requirements

- Change only the wrapped on-premise module version from 1.29.2 to 1.30.0.
- Preserve the wrapper interface and all default behavior.
- Regenerate module documentation and verify Terraform resolves v1.30.0.

## Compatibility

This is a backward-compatible dependency update. No wrapper inputs, outputs, providers, or resources are changed directly.
