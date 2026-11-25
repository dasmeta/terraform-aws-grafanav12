output "cloudwatch_slack" {
  value       = try(module.cloudwatch_slack[0], null)
  description = "CloudWatch Slack adapter function, source topics and failed-invocation queue; null when disabled."
}
