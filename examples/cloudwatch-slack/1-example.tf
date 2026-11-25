# Use the existing cluster/provider and Grafana authentication configuration.
# This example adds adapter ownership without importing source SNS topics.
module "monitoring" {
  source       = "../../"
  cluster_name = var.cluster_name
  alerts = {
    contact_points = {
      slack = [{ name = "Slack", webhook_url = var.slack_webhook_url }]
    }
  }
  cloudwatch_slack = {
    enabled               = true
    topic_arn             = var.primary_topic_arn
    additional_topic_arns = var.additional_topic_arns
  }
}
