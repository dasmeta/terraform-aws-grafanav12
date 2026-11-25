# CloudWatch Slack example

Supply existing cluster/topic/webhook values securely; see the root README for authentication and approved runtime validation.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>5.0 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | ~>4.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_monitoring"></a> [monitoring](#module\_monitoring) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_additional_topic_arns"></a> [additional\_topic\_arns](#input\_additional\_topic\_arns) | Additional existing topics in default-enabled commercial regions. | `set(string)` | `[]` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Existing cluster managed by the monitoring setup. | `string` | n/a | yes |
| <a name="input_grafana_url"></a> [grafana\_url](#input\_grafana\_url) | Existing Grafana URL; authentication is supplied through GRAFANA\_AUTH. | `string` | n/a | yes |
| <a name="input_primary_topic_arn"></a> [primary\_topic\_arn](#input\_primary\_topic\_arn) | Existing same-account standard topic in eu-central-1. | `string` | n/a | yes |
| <a name="input_slack_webhook_url"></a> [slack\_webhook\_url](#input\_slack\_webhook\_url) | Existing monitoring Slack incoming webhook, supplied securely. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
