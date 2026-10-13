# Plan

## Current state

The AWS wrapper pins `dasmeta/grafana/onpremise` 1.29.2 in `main.tf` and documents that pin in `README.md`.

## Change

Update the version to 1.30.0 and regenerate generated documentation. The wrapper remains an opinionated AWS integration layer; its consumer interface is unchanged.

## Governance

This repository does not have a bootstrapped `.specify` command environment, so this package provides the required release-bump evidence. No new capability is introduced, so the Modern Capabilities Rule is not applicable. No breaking or interface-widening change is proposed.

## Verification

Run `terraform init -upgrade -input=false`, verify the selected module source is 1.30.0, run `terraform validate`, and run `pre-commit run --all-files`.
