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
        name = "service-and-email"
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
