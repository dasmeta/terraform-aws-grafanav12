# Feature Specification: Optional CloudWatch Slack routing

**Branch**: 009-cloudwatch-slack
**Created**: 2026-11-25
**Status**: Ready for implementation
**Input**: Extend the shared Grafana AWS module so consumers can configure existing CloudWatch SNS alarm topics to use their existing Slack contact point in the same environment module.

## User Scenarios & Testing
### US1: Opt-in delivery (P1)
A consumer enables one grouped cloudwatch_slack input, identifies an existing primary topic in the default provider region and reuses a named webhook-based Slack contact point. Plan creates one adapter, source-scoped permissions, bounded logs and a failed-invocation queue; existing topics/policies/subscribers and Grafana behavior remain unchanged. Disabled defaults add no resources.
### US2: Additional regions (P2)
Additional same-account standard SNS topic ARNs in default-enabled commercial regions can notify the same function, without new provider aliases or raising the AWS provider floor. Independently verify unique resource identities and topic-derived region values; existing topics are not adopted or mutated.
### US3: Safe lifecycle (P1)
Malformed, cross-account, FIFO or unsupported-region topics and absent webhook contact points fail clearly before deployment. Topic order does not change identities. Disabling removes only feature-owned resources and requires preserving failed-event evidence. No secret appears in examples, output, stack templates or assertions.

## Requirements
- FR-001: New behavior is disabled by default and all existing required/optional inputs and provider requirements stay compatible.
- FR-002: Group enabled, topic_arn, additional_topic_arns, contact_point, optional function_name and log_retention_days in one narrow object; document every field inline.
- FR-003: Reuse an existing named Slack incoming webhook; do not expose the full upstream Lambda surface.
- FR-004: Wrap the maintained notification module and DasMeta SQS capability, preserving topic ownership.
- FR-005: Support source topics in the default provider region and additional default-enabled commercial regions using existing AWS provider ~>5.0 capabilities.
- FR-006: Plan tests verify disabled defaults, local/cross-region routing, source scoping, deterministic IDs, secrets boundary, invalid inputs and adapter logs/DLQ.
- FR-007: README, independent usage example and native tests document initialization, rollout rights and an approved disposable delivery/lifecycle test.

## Success Criteria
Existing consumer tests continue passing; new plan tests demonstrate exact resource boundaries and reject invalid configurations. A reviewer can inspect reusable source without any consumer identifiers. A separately approved disposable two-region delivery/removal/destroy exercise is required before runtime success is claimed.

## Scope, ownership, records and risks
Module maintainers own review/release; the operator owns source preparation. Canonical inputs are the user instruction, existing module interfaces and primary AWS/upstream documentation. No production mutation, topic creation/adoption, public release or customer identifiers. CloudBrowser access returned 401, so no catalog writes. Cross-region subscriptions use a CloudFormation SNS resource handler; deployment IAM/SCPs must permit its regional SNS operations. Existing-topic policies and subscribers retain their owners. Preserve DLQ evidence before rollback.
