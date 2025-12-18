module "this" {
  source  = "dasmeta/grafana/onpremise"
  version = "1.27.2"

  application_dashboard          = var.application_dashboard
  deploy_grafana_stack_dashboard = var.deploy_grafana_stack_dashboard

  alerts = var.alerts

  grafana = provider::deepmerge::mergo(var.grafana, {
    namespace       = coalesce(var.grafana.namespace, var.namespace)
    ingress         = local.grafana_ingress
    datasources     = local.grafana_datasources
    service_account = local.grafana_service_account
  })

  tempo = provider::deepmerge::mergo(var.tempo, {
    service_account = local.tempo_service_account

    storage = {
      backend               = var.tempo.storage.backend
      backend_configuration = length(var.tempo.storage.backend_configuration) > 0 ? var.tempo.storage.backend_configuration : local.tempo_default_s3_configs
    }
    namespace = coalesce(var.tempo.namespace, var.namespace)
  })

  loki_stack = provider::deepmerge::mergo(var.loki_stack, {
    namespace = coalesce(var.loki_stack.namespace, var.namespace)

    loki = {
      serviceAccount = {
        annotations = provider::deepmerge::mergo({ "eks.amazonaws.com/role-arn" : try(module.s3_eks_role.arn, "") }, var.loki_stack.loki.serviceAccount.annotations)
      }
      storage = provider::deepmerge::mergo(local.loki_default_s3_configs, var.loki_stack.loki.storage) # here we prefer custom passed storage configs over the internal generated s3 storage one
    }
  })

  prometheus = provider::deepmerge::mergo(var.prometheus, {
    ingress   = local.prometheus_ingress
    namespace = coalesce(var.prometheus.namespace, var.namespace)
  })

  grafana_admin_password = var.grafana_admin_password
}


module "loki_bucket" {
  source  = "dasmeta/s3/aws"
  version = "1.3.2"

  name = local.loki_s3_bucket_name

  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
}

module "tempo_bucket" {
  source  = "dasmeta/s3/aws"
  version = "1.3.2"

  name = local.tempo_s3_bucket_name

  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
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
        value = ["system:serviceaccount:${var.namespace}:${var.loki_stack.loki.serviceAccount.name}", "system:serviceaccount:${var.namespace}:${var.tempo.service_account.name}"]
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
        value = ["system:serviceaccount:${var.namespace}:${var.grafana.service_account.name}"]
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
