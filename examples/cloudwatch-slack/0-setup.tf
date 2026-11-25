terraform {
  required_version = "~> 1.3"
  required_providers {
    aws     = { source = "hashicorp/aws", version = "~>5.0" }
    grafana = { source = "grafana/grafana", version = "~>4.0" }
  }
}
provider "aws" { region = "eu-central-1" }
provider "grafana" { url = var.grafana_url }
variable "cluster_name" {
  type        = string
  description = "Existing cluster managed by the monitoring setup."
}
variable "grafana_url" {
  type        = string
  description = "Existing Grafana URL; authentication is supplied through GRAFANA_AUTH."
}
variable "slack_webhook_url" {
  type        = string
  sensitive   = true
  description = "Existing monitoring Slack incoming webhook, supplied securely."
}
variable "primary_topic_arn" {
  type        = string
  description = "Existing same-account standard topic in eu-central-1."
}
variable "additional_topic_arns" {
  type        = set(string)
  default     = []
  description = "Additional existing topics in default-enabled commercial regions."
}
