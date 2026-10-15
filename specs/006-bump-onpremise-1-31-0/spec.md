# Bump on-premise Grafana to v1.31.0

## Goal

Update the AWS Grafana wrapper to consume the released `dasmeta/grafana/onpremise` v1.31.0 module.

## Requirements

- Change only the wrapped on-premise module version from 1.30.0 to 1.31.0.
- Preserve the wrapper interface, including the direct `application_dashboard` pass-through.
- Regenerate generated documentation and verify Terraform resolves v1.31.0.

## Compatibility

This is a backward-compatible dependency update. No wrapper inputs, outputs, providers, or resources are changed directly.
