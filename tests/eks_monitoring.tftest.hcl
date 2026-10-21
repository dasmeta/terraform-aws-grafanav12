mock_provider "aws" {
  mock_data "aws_eks_cluster" {
    defaults = {
      identity = [{ oidc = [{ issuer = "https://oidc.eks.eu-central-1.amazonaws.com/id/EXAMPLE" }] }]
    }
  }
  mock_data "aws_caller_identity" {
    defaults = { account_id = "123456789012" }
  }
  mock_data "aws_region" {
    defaults = { name = "eu-central-1" }
  }
  mock_data "aws_iam_policy_document" {
    defaults = { json = "{}" }
  }
}
mock_provider "helm" {}
mock_provider "grafana" {}
mock_provider "random" {}
mock_provider "time" {}

variables {
  cluster_name           = "example"
  grafana_admin_password = "example"
}

run "karpenter_monitoring_is_enabled_by_default" {
  command = plan

  assert {
    condition     = length(module.karpenter_dashboard) == 1 && length(module.karpenter_dashboard[0].widget_alert_rules) > 0
    error_message = "karpenter dashboard must be created by default"
  }

  assert {
    condition     = length(local.prometheus_karpenter_scrape_configs) == 1 && length(local.victoria_metrics_karpenter_scrape_configs) == 0
    error_message = "karpenter scrape config must go to the active collector(prometheus by default) only"
  }

  assert {
    condition     = length([for rule in flatten(module.karpenter_dashboard[*].widget_alert_rules) : rule if strcontains(rule.name, "Karpenter: node is stuck in drifted state for more than 24 hours")]) == 1
    error_message = "drift alert(24h) must be created by default"
  }

  assert {
    condition = alltrue([
      length([for rule in flatten(module.karpenter_dashboard[*].widget_alert_rules) : rule if strcontains(try(rule.expr, ""), "kube_deployment_status_replicas_available{deployment='karpenter', namespace='karpenter'}")]) > 0,
      length([for rule in flatten(module.karpenter_dashboard[*].widget_alert_rules) : rule if strcontains(try(rule.expr, ""), "container_memory_working_set_bytes{container='controller', namespace='karpenter'}")]) == 1,
      length([for rule in flatten(module.karpenter_dashboard[*].widget_alert_rules) : rule if strcontains(try(rule.expr, ""), "container_cpu_usage_seconds_total{container='controller'")]) == 0,
    ])
    error_message = "controller service alerts must use karpenter deployment/controller container and skip cpu"
  }

  assert {
    condition = alltrue([
      length([for rule in flatten(module.karpenter_dashboard[*].widget_alert_rules) : rule if strcontains(rule.name, "Karpenter: interruption messages are not handled")]) == 1,
      length([for panel in flatten(module.karpenter_dashboard[*].widget_result) : panel if try(panel.title, "") == "Interruption messages received / handled"]) == 1,
    ])
    error_message = "EKS karpenter uses the SQS interruption queue, so the opt-in interruption widgets/alert must be on in this module"
  }

  assert {
    condition = alltrue([
      length([for panel in flatten(module.karpenter_dashboard[*].widget_result) : panel if try(panel.title, "") == "Karpenter controller service state (kubernetes native metrics)"]) == 1,
      length([for panel in flatten(module.karpenter_dashboard[*].widget_result) : panel if try(panel.title, "") == "Karpenter exposed metrics based widgets"]) == 1,
    ])
    error_message = "karpenter dashboard rows must have descriptive titles"
  }

  assert {
    condition     = alltrue([for rule in flatten(module.karpenter_dashboard[*].widget_alert_rules) : rule.no_data_state == "OK" if strcontains(rule.group, "arpenter")])
    error_message = "karpenter alerts must not fire on clusters without karpenter(no data is OK)"
  }

  assert {
    condition     = alltrue([for rule in flatten(module.karpenter_dashboard[*].widget_alert_rules) : rule.group == "Karpenter" && rule.labels.namespace == "karpenter"])
    error_message = "controller and karpenter alerts must share the Karpenter group and carry the namespace label"
  }

  assert {
    condition = alltrue([
      length([for rule in flatten(module.karpenter_dashboard[*].widget_alert_rules) : rule if strcontains(rule.name, "has no any running replica/pod") && rule.pending_period == "1m"]) == 1,
      length([for rule in flatten(module.karpenter_dashboard[*].widget_alert_rules) : rule if strcontains(rule.name, "has too many restarts") && rule.pending_period == "2m"]) == 1,
    ])
    error_message = "controller no-replica(1m) and restarts(2m) alerts must wait before firing"
  }
}

run "karpenter_monitoring_with_user_dashboards_and_victoria_metrics" {
  command = plan

  variables {
    metrics_collector = "victoria_metrics"
    victoria_metrics  = { enabled = true, operator = { enabled = true } }
    application_dashboard = [
      {
        name = "Example app"
        rows = [{ type = "block/service", name = "example", namespace = "prod" }, [{ type = "text/title", text = "example" }]]
      }
    ]
  }

  assert {
    condition     = length(local.victoria_metrics_karpenter_scrape_configs) == 1 && length(local.prometheus_karpenter_scrape_configs) == 0
    error_message = "with victoria_metrics collector the scrape config must go to the vmagent"
  }

  assert {
    condition     = length([for rule in flatten(module.karpenter_dashboard[*].widget_alert_rules) : rule if strcontains(rule.name, "Karpenter: node is stuck in drifted state")]) == 1
    error_message = "user dashboards and karpenter dashboard must work together"
  }
}

run "karpenter_monitoring_is_customizable" {
  command = plan

  variables {
    eks_monitoring = {
      karpenter = {
        namespace = "kube-system"
        dashboard = { widgets = { controller = false, interruption = false } }
        alerts = {
          service   = { restarts = { enabled = false }, cpu = { enabled = true, threshold = 1 } }
          karpenter = { node_drift_stuck = { threshold_hours = 48 }, pods_pending = { enabled = false }, interruption_not_handled = { enabled = false } }
        }
      }
    }
  }

  assert {
    condition = alltrue([
      length([for rule in flatten(module.karpenter_dashboard[*].widget_alert_rules) : rule if strcontains(rule.name, "Karpenter: node is stuck in drifted state for more than 48 hours") && strcontains(rule.expr, "namespace=\"kube-system\"")]) == 1,
      length([for rule in flatten(module.karpenter_dashboard[*].widget_alert_rules) : rule if strcontains(rule.name, "pods are pending")]) == 0,
      length([for rule in flatten(module.karpenter_dashboard[*].widget_alert_rules) : rule if strcontains(try(rule.expr, ""), "kube_pod_container_status_restarts_total{") && strcontains(try(rule.expr, ""), "controller")]) == 0,
      length([for rule in flatten(module.karpenter_dashboard[*].widget_alert_rules) : rule if strcontains(try(rule.expr, ""), "container_cpu_usage_seconds_total{container='controller'")]) == 1,
      length([for rule in flatten(module.karpenter_dashboard[*].widget_alert_rules) : rule if strcontains(rule.name, "Karpenter: interruption messages are not handled")]) == 0,
    ])
    error_message = "karpenter alerts must follow namespace, threshold and enable overrides, module defaults(cpu off, interruption on) must be overridable both ways"
  }

  assert {
    condition     = length([for panel in flatten(module.karpenter_dashboard[*].widget_result) : panel if try(panel.title, "") == "Interruption messages received / handled"]) == 0
    error_message = "the module default interruption = true must be overridable with false"
  }
}

run "karpenter_dashboard_creates_its_folder_by_default" {
  command = plan

  assert {
    condition     = local.karpenter_dashboard_create_folder == true && length(local.karpenter_dashboard_folder_uids) == 0
    error_message = "without an existing folder the karpenter dashboard must create its EKS folder"
  }
}

run "karpenter_dashboard_uses_existing_folder_uid" {
  command = plan

  variables {
    eks_monitoring = { karpenter = { dashboard = { folder_uid = "existing-eks-folder" } } }
  }

  assert {
    condition     = local.karpenter_dashboard_create_folder == false && length(local.karpenter_dashboard_folder_uids) == 1 && local.karpenter_dashboard_folder_uids["EKS"] == "existing-eks-folder"
    error_message = "folder_uid must point the dashboard and alerts at the existing folder without creating another one"
  }
}

run "karpenter_dashboard_looks_up_existing_folder_by_title" {
  command = plan

  variables {
    eks_monitoring = { karpenter = { dashboard = { create_folder = false } } }
  }

  assert {
    condition     = local.karpenter_dashboard_create_folder == false && length(local.karpenter_dashboard_folder_uids) == 0
    error_message = "create_folder = false must look up the existing folder by title instead of creating it"
  }
}

run "karpenter_monitoring_can_be_disabled" {
  command = plan

  variables {
    eks_monitoring = { karpenter = { enabled = false } }
  }

  assert {
    condition     = length(module.karpenter_dashboard) == 0 && length(local.prometheus_karpenter_scrape_configs) == 0 && length([for rule in flatten(module.karpenter_dashboard[*].widget_alert_rules) : rule if strcontains(rule.group, "arpenter")]) == 0
    error_message = "karpenter monitoring must be fully removable"
  }
}
