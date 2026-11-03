# Implementation Plan: AWS Grafana Wrapper On-Premise 1.33.2

**Goal:** Consume on-premise Grafana `1.33.2` through the AWS wrapper.

## Current State

`main.tf` pins the root on-premise module and its dashboard child module to
`1.33.1`. The wrapper already forwards its grouped `tempo` object, but that
object's type omits the upstream `service_graph_dimensions` setting.

## Change

Update both pins to `1.33.2`, and add
`service_graph_dimensions = optional(list(string), [])` to the grouped `tempo`
object. It is forwarded by the existing `tempo = mergo(var.tempo, ...)` call.
This is a small, optional interface expansion explicitly approved by the user;
the Modern Capabilities Rule is not applicable because the setting is an
existing upstream Tempo configuration, not a new provider capability. This
package satisfies the repository's Speckit evidence convention.

## Validation

Add a Terraform plan test that supplies dimensions, run it once before the
variable is added to demonstrate the unsupported input, then add the optional
field and run the test again. Also run `terraform init -upgrade -backend=false`,
confirm both modules resolve at `1.33.2`, then run formatting, validation, the
native Terraform test suite, pre-commit, and `git diff --check`.
