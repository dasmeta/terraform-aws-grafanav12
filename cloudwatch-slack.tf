locals {
  cloudwatch_slack_contact_points = [for point in try(coalesce(var.alerts.contact_points.slack, []), []) : point if point.name == var.cloudwatch_slack.contact_point]
  cloudwatch_slack_webhook        = try(coalesce(local.cloudwatch_slack_contact_points[0].webhook_url, ""), "")
  cloudwatch_slack_recipient      = try(coalesce(local.cloudwatch_slack_contact_points[0].recipient, ""), "")
}

module "cloudwatch_slack" {
  count                 = var.cloudwatch_slack.enabled ? 1 : 0
  source                = "./modules/cloudwatch-slack"
  name                  = coalesce(var.cloudwatch_slack.function_name, var.name_prefix == "" ? "grafana-cloudwatch-slack" : "${var.name_prefix}-grafana-cloudwatch-slack")
  topic_arn             = var.cloudwatch_slack.topic_arn
  additional_topic_arns = var.cloudwatch_slack.additional_topic_arns
  webhook_url           = local.cloudwatch_slack_webhook
  channel               = local.cloudwatch_slack_recipient
  log_retention_days    = var.cloudwatch_slack.log_retention_days
}
