output "lambda_function_arn" {
  value       = module.notify_slack.notify_slack_lambda_function_arn
  description = "ARN of the shared notification Lambda."
}
output "topic_arns" {
  value       = setunion(toset([var.topic_arn]), var.additional_topic_arns)
  description = "Existing topics whose new Slack subscriptions are managed by this adapter."
}
output "dead_letter_queue_arn" {
  value       = module.dead_letter_queue.queue_arn
  description = "Failed asynchronous notification invocation queue; preserve its evidence before removal."
}
