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

run "heterogeneous_application_dashboard_rows_are_accepted" {
  command = plan

  variables {
    application_dashboard = [
      {
        name = "a-service-and-email"
        rows = [
          {
            type      = "block/service"
            name      = "worker"
            namespace = "example"
            alerts    = { enabled = false }
          },
          {
            type           = "block/aws-ses"
            block_name     = "Email"
            region         = "eu-central-1"
            datasource_uid = "cloudwatch"
            max            = 100
          },
        ]
      },
      {
        name     = "availability"
        defaults = { period = "1d" }
        rows = [
          {
            type             = "block/sla"
            name             = ""
            namespace        = "example"
            sla_ingress_type = "nginx"
            datasource_uid   = "prometheus"
            alerts           = { enabled = false }
          },
        ]
      },
    ]
  }

  assert {
    condition     = contains(keys(module.this.blocks_by_type), "service")
    error_message = "heterogeneous application dashboard rows must reach the on-premise dashboard module"
  }
}

run "heterogeneous_victoria_metrics_scrape_jobs_are_accepted" {
  command = plan

  variables {
    metrics_collector = "victoria_metrics"
    prometheus        = { enabled = false }
    victoria_metrics = {
      enabled  = true
      operator = { enabled = true }
      agent = {
        extra_scrape_configs = [
          { job_name = "discovery", kubernetes_sd_configs = [{ role = "pod" }] },
          { job_name = "static", scrape_interval = "15s", static_configs = [{ targets = ["example.invalid:9090"] }] },
          { job_name = "relabeled", relabel_configs = [{ action = "keep", regex = "example" }] },
        ]
      }
    }
  }

  assert {
    condition     = module.this.metrics_collector_status.victoria_metrics_agent_enabled
    error_message = "Differently shaped scrape jobs must pass through the AWS wrapper to the VictoriaMetrics agent."
  }
}
