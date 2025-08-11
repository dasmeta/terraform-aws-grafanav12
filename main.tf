module "this" {
  source = "../terraform-onpremise-grafana"
  # version = "1.24.1"

  name = var.deployment_name

  application_dashboard = var.application_dashboard

  alerts = var.alerts

  grafana = {
    enabled           = var.grafana.enabled
    resources         = var.grafana.resources
    ingress           = local.grafana_ingress
    database          = var.grafana.database
    persistence       = var.grafana.persistence
    redundancy        = var.grafana.redundancy
    datasource        = var.grafana.datasources
    trace_log_mapping = var.grafana.trace_log_mapping
    replicas          = var.grafana.replicas
    service_account   = local.grafana_service_account
  }

  tempo = {
    enabled                = var.tempo.enabled
    enable_service_monitor = var.tempo.enable_service_monitor
    metrics_generator      = var.tempo.metrics_generator
    persistence            = var.tempo.persistence
    service_account        = local.tempo_service_account

    storage = {
      backend               = var.tempo.storage.backend
      backend_configuration = length(var.tempo.storage.backend_configuration) > 0 ? var.tempo.storage.backend_configuration : local.tempo_default_s3_configs
    }
  }

  loki = {
    enabled  = true
    loki     = local.loki_configs
    promtail = local.promtail_configs
  }

  prometheus = {
    enabled             = var.prometheus.enabled
    retention_days      = var.prometheus.retention_days
    storage_class       = var.prometheus.storage_class
    storage_size        = var.prometheus.storage_size
    access_modes        = var.prometheus.access_modes
    resources           = var.prometheus.resources
    replicas            = var.prometheus.replicas
    enable_alertmanager = var.prometheus.enable_alertmanager
    ingress             = local.prometheus_ingress
  }


  grafana_admin_password = "adminPassport333"

}


module "loki_bucket" {
  source  = "dasmeta/s3/aws"
  version = "1.3.2"

  name = local.loki_s3_bucket_name
}

module "tempo_bucket" {
  source  = "dasmeta/s3/aws"
  version = "1.3.2"

  name = local.tempo_s3_bucket_name
}

module "s3_eks_role" {
  source  = "dasmeta/iam/aws//modules/role"
  version = "1.3.0"

  name   = "s3-grafanastack-role"
  policy = local.s3_aws_policies
  trust_relationship = [
    {
      principals = {
        type        = "Federated"
        identifiers = [local.eks_oidc_provider_arn]
      }
      conditions = [{
        type  = "StringEquals"
        key   = "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub"
        value = ["system:serviceaccount:${var.namespace}:${var.loki.service_account.name}", "system:serviceaccount:${var.namespace}:${var.tempo.service_account.name}"]
      }]
      actions = ["sts:AssumeRoleWithWebIdentity"]
    }
  ]
}

module "grafana_cloudwatch_role" {
  source  = "dasmeta/iam/aws//modules/role"
  version = "1.3.0"

  name   = "grafana-cloudwatch-role"
  policy = local.cloudwatch_policies
  trust_relationship = [
    {
      principals = {
        type        = "Federated"
        identifiers = [local.eks_oidc_provider_arn]
      }
      conditions = [{
        type  = "StringEquals"
        key   = "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub"
        value = ["system:serviceaccount:${var.namespace}:grafana-service-account"]
      }]
      actions = ["sts:AssumeRoleWithWebIdentity"]
    }
  ]
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}
