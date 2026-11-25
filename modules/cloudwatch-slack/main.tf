data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_sns_topic" "primary" {
  name = local.topic_name
  lifecycle {
    precondition {
      condition     = startswith(var.topic_arn, "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:")
      error_message = "The primary topic must belong to the current account and default AWS provider region."
    }
  }
}

data "aws_regions" "default_enabled" {
  count       = length(var.additional_topic_arns) > 0 ? 1 : 0
  all_regions = true
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "dead_letter_queue" {
  source          = "dasmeta/modules/aws//modules/sqs"
  version         = "1.5.1"
  name            = "${var.name}-dead-letter"
  create_iam_user = false
}

module "notify_slack" {
  source                                 = "terraform-aws-modules/notify-slack/aws"
  version                                = "6.7.0"
  create_sns_topic                       = false
  subscription_filter_policy             = jsonencode(local.cloudwatch_filter_policy)
  subscription_filter_policy_scope       = "MessageBody"
  sns_topic_name                         = data.aws_sns_topic.primary.name
  lambda_function_name                   = var.name
  runtime                                = "python3.12"
  slack_webhook_url                      = var.webhook_url
  slack_channel                          = var.channel
  slack_username                         = "CloudWatch"
  cloudwatch_log_group_retention_in_days = var.log_retention_days
  lambda_dead_letter_target_arn          = module.dead_letter_queue.queue_arn
  lambda_attach_dead_letter_policy       = true
}

resource "aws_lambda_permission" "additional_topic" {
  for_each       = local.additional_topics
  statement_id   = "AllowSNS${substr(sha256(each.key), 0, 32)}"
  action         = "lambda:InvokeFunction"
  function_name  = module.notify_slack.notify_slack_lambda_function_name
  principal      = "sns.amazonaws.com"
  source_arn     = each.key
  source_account = data.aws_caller_identity.current.account_id
  lifecycle {
    precondition {
      condition     = try(split(":", each.key)[4], "") == data.aws_caller_identity.current.account_id && contains(data.aws_regions.default_enabled[0].names, each.value.region) && contains(data.aws_regions.default_enabled[0].names, data.aws_region.current.name) && each.key != var.topic_arn
      error_message = "Additional topics must be distinct from the primary, belong to the current account and use default-enabled commercial regions."
    }
  }
}

# The Region property selects each source topic's SNS client for create/delete.
# This preserves the existing AWS provider contract without region aliases.
resource "aws_cloudformation_stack" "additional_topics" {
  count = length(var.additional_topic_arns) > 0 ? 1 : 0
  name  = "${replace(var.name, "_", "-")}-${substr(sha256(var.name), 0, 8)}-sources"
  template_body = jsonencode({
    AWSTemplateFormatVersion = "2010-09-09"
    Description              = "Existing SNS topic subscriptions for the CloudWatch Slack adapter"
    Resources = {
      for arn, topic in local.additional_topics : topic.logical_id => {
        Type = "AWS::SNS::Subscription"
        Properties = {
          Protocol          = "lambda"
          FilterPolicy      = local.cloudwatch_filter_policy
          FilterPolicyScope = "MessageBody"
          TopicArn          = arn
          Region            = topic.region
          Endpoint          = module.notify_slack.notify_slack_lambda_function_arn
        }
      }
    }
  })
  depends_on = [aws_lambda_permission.additional_topic]
}
