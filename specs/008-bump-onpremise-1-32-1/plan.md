# Implementation Plan: Bump On-Premise Grafana Dependency to 1.32.1

## Summary

Update the AWS wrapper's nested `dasmeta/grafana/onpremise` dependency from
the published `1.32.0` to the published `1.32.1` scrape-fix release. The
existing AWS wrapper interface remains unchanged.

## Scope and standards

- The wrapper is an existing opinionated module; this is a dependency pin
  update, not a new capability or upstream pass-through expansion.
- No public input, output, provider constraint, resource address, or behavior
  besides inheriting the documented child fix changes.
- There is no breaking change or interface widening.
- Modern Capabilities Rule: not applicable. This update introduces no
  provider-specific feature.
- The module-change gate is satisfied by this spec, plan, tasks, validation,
  and review evidence.

## Files

| File | Change |
| --- | --- |
| `main.tf` | Pin `module.this` to `dasmeta/grafana/onpremise` `1.32.1`. |
| `README.md` | Update human-readable and generated dependency references. |
| `specs/008-bump-onpremise-1-32-1/` | Record scope, validation, and release handoff. |

## Validation

1. Confirm the child release is published on the Terraform Registry.
2. Run `terraform init -backend=false`; inspect the lock file resolution
   without committing the transient lock file if this repository does not
   track it.
3. Run `terraform fmt -check -recursive`, `terraform validate`, and the
   repository Terraform documentation hook.
4. Inspect `git diff --check` and review for unintentional interface changes.

## Release handoff

Publish a patch release of `dasmeta/grafanav12/aws`. Only after it is published
should the consumer select the new AWS wrapper version and run its Terraform
plan.
