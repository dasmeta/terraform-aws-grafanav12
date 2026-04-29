# multi-environment-alert-routing

Dedicated AWS test scenario for same-cluster namespace/environment alert routing using existing `alerts.notifications.policies[*].matchers`.

This scenario stays separate from `tests/base` to keep baseline coverage unchanged.

It validates:
- Environment-specific routing for `env=dev|stage|prod`
- Fallback routing to `ops-fallback` when `env` label does not match (or is missing)

Run locally:

```bash
terraform init
terraform validate
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | ~> 4.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.17 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.17.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | dasmeta/eks/aws | 2.25.5 |
| <a name="module_this"></a> [this](#module\_this) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.http_echo](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_subnets.subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpcs.ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpcs) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_slack_webhook_url"></a> [slack\_webhook\_url](#input\_slack\_webhook\_url) | Slack webhook URL used by routing contact points in this scenario | `string` | `"https://hooks.slack.com/services/xxxxx/yyyyyy/zzzzzzzzzzzz"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
