# Contract: Alert Inputs

## `alerts.rules[*]`

The AWS wrapper accepts the following downstream-compatible custom rule fields:

```hcl
{
  name                 = string
  datasource           = string
  datasource_type      = optional(string, "prometheus")
  interval_ms          = optional(number, 1000)
  pending_period       = optional(string, "0")
  condition            = optional(string, null)
  expr                 = optional(string, null)
  equation             = string
  threshold            = number
  folder_name          = optional(string, null)
  no_data_state        = optional(string, "NoData")
  exec_err_state       = optional(string, "Error")
  labels               = optional(map(any), {})
  annotations          = optional(map(string), {})
  group                = optional(string, "custom")
  metric_name          = optional(string, "")
  metric_function      = optional(string, "")
  metric_interval      = optional(string, "")
  settings_mode        = optional(string, "replaceNN")
  settings_replaceWith = optional(number, 0)
  filters              = optional(any, {})
  function             = optional(string, "mean")
}
```

## `alerts.disk_capacity`

The AWS wrapper accepts the downstream-compatible disk-capacity alert object:

```hcl
{
  enabled              = optional(bool, true)
  folder_name          = optional(string, null)
  group                = optional(string, "storage")
  datasource           = optional(string, null)
  datasource_type      = optional(string, "prometheus")
  namespace            = optional(string, ".*")
  pvc                  = optional(string, ".*")
  threshold            = optional(number, 90)
  pending_period       = optional(string, "5m")
  no_data_state        = optional(string, "NoData")
  exec_err_state       = optional(string, "Error")
  interval_ms          = optional(number, 1000)
  function             = optional(string, "last")
  settings_mode        = optional(string, "replaceNN")
  settings_replaceWith = optional(number, 0)
  labels               = optional(map(any), {})
  annotations          = optional(map(string), {})
}
```
