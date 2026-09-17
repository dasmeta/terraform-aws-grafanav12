# base

This example installs both backends and selects the Operator-managed VMAgent
with `metrics_collector = "victoria_metrics"`. It intentionally uses the same
`prometheus` and `victoria_metrics` objects as `tests/base`; only the selector
differs.

Local contract and validation commands:

```sh
cd /Users/vazgen/work/Dasmeta/modules/terraform-aws-grafanav12
terraform init -backend=false -lockfile=readonly
printf '%s\n' '[var.victoria_metrics.operator.chart_version, var.victoria_metrics.operator.release_name, var.victoria_metrics.agent.name, tostring(var.victoria_metrics.agent.replica_count)]' | terraform console -var='grafana_admin_password=wrapper-contract-non-secret' -var-file=tests/metrics-collector-selection/contract.tfvars
terraform validate

cd tests/base
terraform init -backend=false -lockfile=readonly
terraform validate

cd ../base-with-victoria-metrics
terraform init -backend=false -lockfile=readonly
terraform validate
```

These checks use the current local sibling source and do not apply resources.
Before a registry-based release, replace it with the real published
selector-enabled base-module version and repeat all checks.

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
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [aws_subnets.subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpcs.ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpcs) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
