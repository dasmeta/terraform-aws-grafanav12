locals {
  cloudwatch_filter_policy = { AlarmName = [{ exists = true }] }
  topic_name               = try(split(":", var.topic_arn)[5], "invalid")
  additional_topics = {
    for arn in var.additional_topic_arns : arn => {
      region     = try(split(":", arn)[3], "invalid")
      logical_id = "Subscription${substr(sha256(arn), 0, 32)}"
    }
  }
}
