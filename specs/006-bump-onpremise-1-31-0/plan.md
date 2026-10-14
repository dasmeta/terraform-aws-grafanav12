# Plan

## Current state

The AWS wrapper pins `dasmeta/grafana/onpremise` v1.30.0 in `main.tf`. Its `application_dashboard` value is already forwarded unchanged to the wrapped module.

## Change

Update the pin to v1.31.0 and regenerate README documentation. The wrapper remains an opinionated AWS integration layer; no consumer interface changes are proposed.

## Governance

This package is manually maintained because the repository's Speckit executable is unavailable in the local environment. The repository already provides Speckit structure and prior dependency-bump packages. No new capability is introduced, so the Modern Capabilities Rule is not applicable. No breaking or interface-widening change is proposed.

## Verification

Run `terraform init -upgrade -input=false`, verify the selected module source is v1.31.0, run `terraform validate`, execute repository pre-commit hooks, and confirm the dashboard pass-through remains direct.
