variable "name" {
  type        = string
  description = "Unique Slack adapter function name; limited to 57 characters to leave room for the upstream IAM role prefix."
  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_-]{0,56}$", var.name))
    error_message = "name must start with a letter and contain at most 57 letters, digits, underscores or hyphens."
  }
}

variable "topic_arn" {
  type        = string
  description = "Existing same-account standard SNS topic in the default AWS provider region; never created or adopted."
  validation {
    condition     = can(regex("^arn:aws:sns:[a-z0-9-]+:[0-9]{12}:[A-Za-z0-9_-]+$", var.topic_arn))
    error_message = "topic_arn must identify a standard commercial AWS SNS topic; FIFO topics are unsupported."
  }
}

variable "additional_topic_arns" {
  type        = set(string)
  default     = []
  description = "Additional existing same-account standard topics in default-enabled commercial regions."
  validation {
    condition     = alltrue([for arn in var.additional_topic_arns : can(regex("^arn:aws:sns:[a-z0-9-]+:[0-9]{12}:[A-Za-z0-9_-]+$", arn))])
    error_message = "additional_topic_arns must contain standard commercial SNS topic ARNs; FIFO topics are unsupported."
  }
}

variable "webhook_url" {
  type        = string
  sensitive   = true
  description = "Existing Slack incoming webhook URL, supplied by the owning contact point."
  validation {
    condition     = can(regex("^https://[^/]+/.+", var.webhook_url))
    error_message = "The selected Slack contact point must provide a non-empty HTTPS incoming webhook URL."
  }
}

variable "channel" {
  type        = string
  default     = ""
  description = "Existing Slack contact point recipient; incoming webhooks may ignore overrides."
}

variable "log_retention_days" {
  type        = number
  default     = 7
  description = "CloudWatch log retention for the notification adapter."
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.log_retention_days)
    error_message = "log_retention_days must be a supported positive CloudWatch Logs retention period."
  }
}
