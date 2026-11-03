# Implementation Plan: AWS Grafana Wrapper On-Premise 1.33.2

**Goal:** Consume on-premise Grafana `1.33.2` through the AWS wrapper.

## Current State

`main.tf` pins the root on-premise module and its dashboard child module to
`1.33.1`. The wrapper is an existing opinionated AWS layer; its interface is
not changed by this update.

## Change

Update both pins to `1.33.2`. No new capability is introduced, so the Modern
Capabilities Rule is not applicable. This package satisfies the repository's
Speckit evidence convention for a module dependency update.

## Validation

Run `terraform init -upgrade -backend=false`, confirm both modules resolve at
`1.33.2`, then run formatting, validation, the native Terraform test suite,
pre-commit, and `git diff --check`.
