mock_provider "aws" {
  override_during = plan
  mock_data "aws_partition" { defaults = { partition = "aws", id = "aws", dns_suffix = "amazonaws.com" } }
  mock_data "aws_caller_identity" { defaults = { account_id = "123456789012" } }
  mock_data "aws_region" { defaults = { name = "eu-central-1" } }
  mock_data "aws_regions" { defaults = { names = ["eu-central-1", "us-east-1", "us-west-2"] } }
  mock_data "aws_iam_policy_document" { defaults = { json = "{}" } }
  mock_resource "aws_lambda_function" { defaults = { arn = "arn:aws:lambda:eu-central-1:123456789012:function:example-cloudwatch-slack" } }
}
mock_provider "external" {
  mock_data "external" {
    defaults = { result = { filename = "mock.zip", build_plan = "{}", build_plan_filename = "mock.plan.json", timestamp = "0", was_missing = "false" } }
  }
}
mock_provider "local" {}
mock_provider "null" {}

override_resource {
  override_during = plan
  target          = module.notify_slack.module.lambda.aws_lambda_function.this[0]
  values          = { arn = "arn:aws:lambda:eu-central-1:123456789012:function:example-cloudwatch-slack", function_name = "example-cloudwatch-slack" }
}
override_resource {
  override_during = plan
  target          = module.dead_letter_queue.module.sqs.aws_sqs_queue.this[0]
  values          = { arn = "arn:aws:sqs:eu-central-1:123456789012:example-cloudwatch-slack-dead-letter" }
}

variables {
  name        = "example-cloudwatch-slack"
  topic_arn   = "arn:aws:sns:eu-central-1:123456789012:account-alarms"
  webhook_url = "https://example.invalid/placeholder"
}

run "local_existing_topic_only" {
  command = plan
  assert {
    condition     = length(aws_lambda_permission.additional_topic) == 0 && length(aws_cloudformation_stack.additional_topics) == 0
    error_message = "Local-only routing must not create an extra stack or cross-region permission."
  }
  assert {
    condition     = module.notify_slack.slack_topic_arn == var.topic_arn
    error_message = "The existing primary topic must be reused."
  }
  assert {
    condition     = module.dead_letter_queue.queue_arn != null
    error_message = "Failed asynchronous notifications require a dead-letter queue."
  }
}

run "two_source_regions" {
  command = plan
  variables { additional_topic_arns = ["arn:aws:sns:us-east-1:123456789012:account-alarms-virginia", "arn:aws:sns:us-east-1:123456789012:legacy-slack"] }
  assert {
    condition     = length(aws_lambda_permission.additional_topic) == 2 && length(aws_cloudformation_stack.additional_topics) == 1
    error_message = "One function must have exact additional-topic permissions and one subscription stack."
  }
  assert {
    condition     = alltrue([for arn, p in aws_lambda_permission.additional_topic : p.source_arn == arn && p.source_account == "123456789012" && p.principal == "sns.amazonaws.com"])
    error_message = "Every invocation grant must be scoped to its exact source topic/account."
  }
  assert {
    condition     = alltrue([for arn, p in aws_lambda_permission.additional_topic : p.statement_id == "AllowSNS${substr(sha256(arn), 0, 32)}"])
    error_message = "Permission identities must be stable and distinct by source ARN."
  }
  assert {
    condition     = alltrue([for k, r in jsondecode(aws_cloudformation_stack.additional_topics[0].template_body).Resources : r.Type == "AWS::SNS::Subscription" && r.Properties.Region == "us-east-1" && r.Properties.Protocol == "lambda" && r.Properties.FilterPolicyScope == "MessageBody" && r.Properties.FilterPolicy.AlarmName[0].exists && r.Properties.Endpoint == "arn:aws:lambda:eu-central-1:123456789012:function:example-cloudwatch-slack" && k == "Subscription${substr(sha256(r.Properties.TopicArn), 0, 32)}"])
    error_message = "Cross-region template must own only deterministic Lambda subscriptions in each source region."
  }
  assert {
    condition     = !strcontains(aws_cloudformation_stack.additional_topics[0].template_body, "example.invalid")
    error_message = "CloudFormation templates must not contain Slack credentials."
  }
}

run "invalid_primary_region" {
  command = plan
  variables { topic_arn = "arn:aws:sns:us-east-1:123456789012:account-alarms" }
  expect_failures = [data.aws_sns_topic.primary]
}
run "invalid_primary_account" {
  command = plan
  variables { topic_arn = "arn:aws:sns:eu-central-1:111111111111:account-alarms" }
  expect_failures = [data.aws_sns_topic.primary]
}
run "fifo_rejected" {
  command = plan
  variables { topic_arn = "arn:aws:sns:eu-central-1:123456789012:account-alarms.fifo" }
  expect_failures = [var.topic_arn]
}
run "missing_webhook_rejected" {
  command = plan
  variables { webhook_url = "" }
  expect_failures = [var.webhook_url]
}
run "additional_account_rejected" {
  command = plan
  variables { additional_topic_arns = ["arn:aws:sns:us-east-1:111111111111:account-alarms"] }
  expect_failures = [aws_lambda_permission.additional_topic]
}
run "opt_in_region_rejected" {
  command = plan
  variables { additional_topic_arns = ["arn:aws:sns:ap-east-1:123456789012:account-alarms"] }
  expect_failures = [aws_lambda_permission.additional_topic]
}
run "duplicate_primary_rejected" {
  command = plan
  variables { additional_topic_arns = ["arn:aws:sns:eu-central-1:123456789012:account-alarms"] }
  expect_failures = [aws_lambda_permission.additional_topic]
}
run "overlong_function_name_rejected" {
  command = plan
  variables { name = "this-function-name-is-too-long-for-the-upstream-iam-role-prefix" }
  expect_failures = [var.name]
}

run "underscore_function_name_has_valid_stack_name" {
  command = plan
  variables {
    name                  = "example_cloudwatch_slack"
    additional_topic_arns = ["arn:aws:sns:us-east-1:123456789012:account-alarms-virginia"]
  }
  assert {
    condition     = can(regex("^[A-Za-z][-A-Za-z0-9]*$", aws_cloudformation_stack.additional_topics[0].name))
    error_message = "Lambda underscores must not produce an invalid CloudFormation stack name."
  }
}
run "opt_in_destination_rejected_for_cross_region_routes" {
  command = plan
  variables {
    topic_arn             = "arn:aws:sns:ap-east-1:123456789012:account-alarms"
    additional_topic_arns = ["arn:aws:sns:us-east-1:123456789012:account-alarms-virginia"]
  }
  override_data {
    target = data.aws_region.current
    values = { name = "ap-east-1" }
  }
  expect_failures = [aws_lambda_permission.additional_topic]
}
