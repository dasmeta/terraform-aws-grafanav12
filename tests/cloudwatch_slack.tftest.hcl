mock_provider "aws" {
  mock_data "aws_eks_cluster" {
    defaults = { identity = [{ oidc = [{ issuer = "https://oidc.eks.eu-central-1.amazonaws.com/id/EXAMPLE" }] }] }
  }
  mock_data "aws_caller_identity" { defaults = { account_id = "123456789012" } }
  mock_data "aws_region" { defaults = { name = "eu-central-1" } }
  mock_data "aws_iam_policy_document" { defaults = { json = "{}" } }
}
mock_provider "helm" {}
mock_provider "grafana" {}
mock_provider "random" {}
mock_provider "time" {}

override_module {
  target  = module.this
  outputs = { folder_uids = {} }
}

override_module {
  target  = module.cloudwatch_slack
  outputs = { lambda_function_arn = "arn:aws:lambda:eu-central-1:123456789012:function:example-cloudwatch-slack" }
}

variables {
  eks_monitoring         = { karpenter = { enabled = false } }
  loki_stack             = { enabled = false }
  tempo                  = { enabled = false }
  cluster_name           = "example"
  grafana_admin_password = "example"
}

run "disabled_by_default" {
  command = plan
  assert {
    condition     = length(module.cloudwatch_slack) == 0
    error_message = "Existing consumers must not create CloudWatch Slack resources by default."
  }
}

run "invalid_primary_topic" {
  command = plan
  variables {
    cloudwatch_slack = { enabled = true, topic_arn = "not-an-arn" }
  }
  expect_failures = [var.cloudwatch_slack]
}

run "enabled_reuses_named_contact_point" {
  command = plan
  variables {
    cloudwatch_slack = {
      enabled   = true
      topic_arn = "arn:aws:sns:eu-central-1:123456789012:account-alarms"
    }
    alerts = {
      contact_points = {
        slack = [
          { name = "Other", webhook_url = "https://example.invalid/other" },
          { name = "Slack", webhook_url = "https://example.invalid/selected", recipient = "monitoring" }
        ]
      }
    }
  }
  assert {
    condition     = length(module.cloudwatch_slack) == 1 && local.cloudwatch_slack_webhook == "https://example.invalid/selected" && local.cloudwatch_slack_recipient == "monitoring"
    error_message = "Enabled routing must reuse the named existing Slack contact point, not the first unrelated one."
  }
}
