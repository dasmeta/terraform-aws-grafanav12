# GitLab SSO Integration Test

This is a minimal test setup for GitLab OAuth2 SSO integration with Grafana on AWS EKS.

## Prerequisites

1. A GitLab OAuth application must be created:
   - Go to GitLab → Profile → Preferences → Applications
   - Create a new OAuth application
   - Set the redirect URI to: `https://grafana-sso-test.devops.dasmeta.com/login/gitlab` (replace with your actual Grafana hostname)
   - Check openid, email, profile in the Scopes list. Leave the Confidential checkbox checked.
   - Copy the Application ID (client_id) and Secret (client_secret)

2. AWS account with appropriate permissions to create:
   - EKS cluster
   - VPC and networking resources
   - IAM roles and policies
   - Load balancers

3. Default VPC should exist in the AWS region (eu-central-1 by default)

## Configuration

Set the GitLab OAuth credentials via environment variables or terraform.tfvars:

```bash
export TF_VAR_gitlab_client_id="your_gitlab_client_id"
export TF_VAR_gitlab_client_secret="your_gitlab_client_secret"
```

Or create a `terraform.tfvars` file:

```hcl
gitlab_client_id     = "your_gitlab_client_id"
gitlab_client_secret = "your_gitlab_client_secret"
```

Optional: Customize the Grafana hostname and admin password:

```bash
export TF_VAR_grafana_hostname="your-grafana-hostname.example.com"
export TF_VAR_grafana_admin_password="your-secure-password"
```

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## What This Test Includes

- EKS cluster setup with required components (ALB controller, external-dns, etc.)
- Minimal Grafana deployment with database persistence
- GitLab OAuth2 SSO configuration
- No other stack components (Prometheus, Tempo, Loki disabled)
- No dashboards or alerts

## GitLab OAuth Application Setup

When creating the GitLab OAuth application, use the following redirect URI:
- **Redirect URI**: `https://grafana-sso-test.devops.dasmeta.com/login/gitlab`

Replace `grafana-sso-test.devops.dasmeta.com` with your actual Grafana ingress hostname configured in `var.grafana_hostname`.

## Testing the Integration

After applying the configuration:

1. Wait for the EKS cluster and Grafana to be fully deployed
2. Get the ALB DNS name (from AWS console or terraform output)
3. Access Grafana at the configured ingress URL (or ALB DNS name if external-dns is not configured)
4. You should see a "Sign in with GitLab" button on the login page
5. Click the button to authenticate via GitLab
6. After successful authentication, you'll be logged into Grafana

## Role Mapping

The example includes default role mapping configuration:

- **GitLab groups** → **Grafana roles**:
  - Users in `grafana-admin` group → **Admin** role
  - Users in `grafana-editor` group → **Editor** role
  - All other users → **Viewer** role (default)

To enable group-based role mapping:
1. Ensure your GitLab OAuth application has `read_api` scope (in addition to `api read_user`)
2. Create GitLab groups named `grafana-admin` and/or `grafana-editor` as needed
3. Add users to the appropriate groups in GitLab
4. Customize the `role_attribute_path` expression if you want different group names or mapping logic

The `role_attribute_path` uses JSONPath expressions to extract role information from the OAuth token. You can customize it based on your GitLab group structure.

## AWS-Specific Notes

- This test creates an EKS cluster in the default VPC
- The cluster uses SPOT instances for cost efficiency
- ALB (Application Load Balancer) is used for ingress instead of nginx
- External DNS integration is enabled (ensure your DNS zone is configured)
- The test uses minimal resources for quick validation
- The Grafana admin password is set to "admin" by default (change in production)

## Notes

- This test uses minimal resources for quick validation
- The Grafana admin password is set to "admin" by default (change in production)
- For GitLab.com, the URLs are pre-configured. For self-hosted GitLab, update the `auth_url`, `token_url`, and `api_url` accordingly
- Role mapping requires GitLab groups to be accessible via the OAuth token. Ensure your OAuth application has appropriate scopes
- The EKS cluster creation may take 10-15 minutes
- Ensure you have appropriate AWS permissions and quotas for EKS cluster creation
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | ~> 4.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.17 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.29 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | dasmeta/eks/aws | 2.24.2 |
| <a name="module_this"></a> [this](#module\_this) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_subnets.subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpcs.ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpcs) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gitlab_client_id"></a> [gitlab\_client\_id](#input\_gitlab\_client\_id) | GitLab OAuth application client ID | `string` | n/a | yes |
| <a name="input_gitlab_client_secret"></a> [gitlab\_client\_secret](#input\_gitlab\_client\_secret) | GitLab OAuth application client secret | `string` | n/a | yes |
| <a name="input_grafana_admin_password"></a> [grafana\_admin\_password](#input\_grafana\_admin\_password) | Grafana admin password | `string` | `"admin"` | no |
| <a name="input_grafana_hostname"></a> [grafana\_hostname](#input\_grafana\_hostname) | Grafana hostname for ingress and provider URL | `string` | `"grafana-sso-test.devops.dasmeta.com"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
