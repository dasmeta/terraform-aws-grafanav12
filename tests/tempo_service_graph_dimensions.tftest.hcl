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

run "tempo_service_graph_dimensions_are_accepted" {
  command = plan

  variables {
    tempo = {
      enabled                  = true
      service_graph_dimensions = ["service.name", "k8s.namespace.name"]
    }
  }

  assert {
    condition     = var.tempo.service_graph_dimensions == ["service.name", "k8s.namespace.name"]
    error_message = "Tempo service-graph dimensions must be retained by the wrapper tempo map"
  }
}
