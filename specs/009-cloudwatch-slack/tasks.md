# Tasks: Optional CloudWatch Slack routing

## Setup and research
- [X] T001 Verify existing provider/wrapper contracts and primary AWS cross-region lifecycle evidence in research.md.
- [X] T002 Execute Spec Kit specification and plan in this repository; record compatibility, secret and release boundaries in plan.md.

## US1: Optional local routing
Independent test: disabled creates no new resources; enabled reuses an existing named webhook and local primary topic.
- [X] T003 [US1] Add failing native contract cases in tests/cloudwatch_slack.tftest.hcl and the submodule test surface.
- [X] T004 [US1] Add narrow root variables/integration and modules/cloudwatch-slack wrapper, logs, dead-letter queue and non-secret outputs.

## US2: Additional regions
Independent test: hash-derived additional topic identities, exact source permissions and region-derived CloudFormation subscriptions; no source topic/policy ownership.
- [X] T005 [US2] Add additional-region subscription template and permissions in modules/cloudwatch-slack; validate topic/account/region boundaries.

## US3: Compatibility and adoption
Independent test: prior consumer tests pass; invalid inputs fail, templates/outputs contain no secrets and docs describe deployment rights/runtime gates.
- [X] T006 [US3] Add independent examples/cloudwatch-slack usage and README documentation, with inline grouped-field descriptions.
- [ ] T007 [US3] Initialize and run actual validate, new and existing native tests, formatting/docs/credential/public-identifier checks; record real results in plan.md.
- [ ] T008 [US3] Review source and metadata, commit/push and open shared-module PR; prepare consumer adoption against the reviewed module commit pending a real release.

Dependencies: T001 -> T002 -> T003 -> T004 -> T005 -> T006 -> T007 -> T008. Implementation is sequential. Independent primary-source research was delegated during planning; no overlapping file edits. MVP includes disabled compatibility and local routing; additional regions and safe adoption deliver in the same module PR. No production deployment, tag publication or merge.
