# CloudWatch SNS Slack adapter

Used by the root module's opt-in `cloudwatch_slack` input. Reuses an existing local primary standard SNS topic and optionally additional same-account topics in default-enabled commercial regions. Source topics, policies, alarms and pre-existing subscribers keep their current owners. One notification Lambda and failed-invocation queue are owned here. New subscriptions filter JSON message bodies for AlarmName so unrelated messages on shared topics are not forwarded.

The root module supplies the existing named Slack contact point's sensitive incoming webhook. This submodule does not create Grafana contact points or expose that credential in outputs or CloudFormation templates. Additional subscriptions use topic-derived `Region` values and stable ARN-hashed identities, and wait for their exact source-scoped Lambda permissions before stack creation.

Initialize before validation or tests:

```sh
terraform init -backend=false
terraform validate
terraform test
```

Native tests require Terraform 1.11+ for plan-time computed-value overrides. The consumer runtime constraint remains unchanged. All test providers are mocked; these checks do not prove deployed delivery. See the root README for regional IAM/SCP requirements and the separately approved disposable two-region lifecycle/delivery check. Preserve failed-invocation evidence before disabling or removing the adapter.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_dead_letter_queue"></a> [dead\_letter\_queue](#module\_dead\_letter\_queue) | dasmeta/modules/aws//modules/sqs | 1.5.1 |
| <a name="module_notify_slack"></a> [notify\_slack](#module\_notify\_slack) | terraform-aws-modules/notify-slack/aws | 6.7.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudformation_stack.additional_topics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack) | resource |
| [aws_lambda_permission.additional_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_regions.default_enabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/regions) | data source |
| [aws_sns_topic.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/sns_topic) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_additional_topic_arns"></a> [additional\_topic\_arns](#input\_additional\_topic\_arns) | Additional existing same-account standard topics in default-enabled commercial regions. | `set(string)` | `[]` | no |
| <a name="input_channel"></a> [channel](#input\_channel) | Existing Slack contact point recipient; incoming webhooks may ignore overrides. | `string` | `""` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | CloudWatch log retention for the notification adapter. | `number` | `7` | no |
| <a name="input_name"></a> [name](#input\_name) | Unique Slack adapter function name; limited to 57 characters to leave room for the upstream IAM role prefix. | `string` | n/a | yes |
| <a name="input_topic_arn"></a> [topic\_arn](#input\_topic\_arn) | Existing same-account standard SNS topic in the default AWS provider region; never created or adopted. | `string` | n/a | yes |
| <a name="input_webhook_url"></a> [webhook\_url](#input\_webhook\_url) | Existing Slack incoming webhook URL, supplied by the owning contact point. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dead_letter_queue_arn"></a> [dead\_letter\_queue\_arn](#output\_dead\_letter\_queue\_arn) | Failed asynchronous notification invocation queue; preserve its evidence before removal. |
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | ARN of the shared notification Lambda. |
| <a name="output_topic_arns"></a> [topic\_arns](#output\_topic\_arns) | Existing topics whose new Slack subscriptions are managed by this adapter. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
