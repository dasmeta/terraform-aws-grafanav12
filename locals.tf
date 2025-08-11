locals {

  # General configurations
  eks_oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}"
  s3_aws_policies = [
    {
      actions   = ["s3:ListBucket"],
      resources = ["arn:aws:s3:::${local.loki_s3_bucket_name}", "arn:aws:s3:::${local.tempo_s3_bucket_name}"]
    },
    {
      actions = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListObjects",
        "s3:DeleteObject",
        "s3:GetObjectTagging",
        "s3:PutObjectTagging"
      ],
      resources = ["arn:aws:s3:::${local.loki_s3_bucket_name}/*", "arn:aws:s3:::${local.tempo_s3_bucket_name}/*"]
    }
  ]

  # Tempo configurations
  tempo_s3_bucket_name = length(var.tempo.bucket_name) > 0 ? var.tempo.bucket_name : "tempo-traces-${var.cluster_name}-${random_string.random.result}"
  tempo_default_s3_configs = {
    s3 = {
      bucket   = local.tempo_s3_bucket_name
      endpoint = "s3.${data.aws_region.current.name}.amazonaws.com"
      region   = data.aws_region.current.name
      insecure = false
    }
  }

  tempo_service_account = {
    name = var.tempo.service_account.name
    annotations = merge(var.grafana.service_account.annotations,
      {
        "eks.amazonaws.com/role-arn" : try(module.s3_eks_role.arn, "")
      }
    )
  }

  # Loki configurations
  loki_s3_bucket_name = length(var.loki.send_logs_s3.bucket_name) > 0 ? var.loki.send_logs_s3.bucket_name : "loki-logs-${var.cluster_name}-${random_string.random.result}"
  loki_default_s3_configs = {
    type = "s3"
    s3 = {
      bucket   = local.loki_s3_bucket_name
      region   = data.aws_region.current.name
      insecure = false
    }
    bucketNames = {
      chunks = local.loki_s3_bucket_name
      ruler  = local.loki_s3_bucket_name
      admin  = local.loki_s3_bucket_name
    }
  }

  loki_configs = {
    volume_enabled = var.loki.volume_enabled
    service_account = {
      enable      = var.loki.service_account.enable
      name        = var.loki.service_account.name
      annotations = merge(var.loki.service_account.annotations, { "eks.amazonaws.com/role-arn" : try(module.s3_eks_role.arn, "") })
    }

    persistence = {
      enabled       = var.loki.persistence.enabled
      size          = var.loki.persistence.size
      storage_class = var.loki.persistence.storage_class
      access_mode   = var.loki.persistence.access_mode
    }
    schema_configs = var.loki.schema_configs
    storage        = merge(length(var.loki.storage) > 0 ? var.loki.storage : local.loki_default_s3_configs)

    ingress = {
      enabled     = var.loki.ingress.enabled
      type        = var.loki.ingress.type
      public      = var.loki.ingress.public
      tls_enabled = var.loki.ingress.tls_enabled

      annotations = var.loki.ingress.additional_annotations
      hosts       = var.loki.ingress.hosts
      path        = var.loki.ingress.path
      path_type   = var.loki.ingress.path_type
    }
    replicas         = var.loki.replicas
    retention_period = var.loki.retention_period
    resources        = var.loki.resources
  }

  default_loki_storage = {
    type = "s3"
    s3 = {
      s3               = local.loki_s3_bucket_name
      region           = data.aws_region.current.name
      s3ForcePathStyle = true
    }

    bucketNames = {
      chunks = local.loki_s3_bucket_name
      ruler  = local.loki_s3_bucket_name
      admin  = local.loki_s3_bucket_name
    }
  }

  # Promtail configurations
  promtail_configs = {
    enabled               = var.loki.promtail.enabled
    log_level             = var.loki.promtail.log_level
    server_port           = var.loki.promtail.server_port
    clients               = var.loki.promtail.clients
    log_format            = var.loki.promtail.log_format
    extra_scrape_configs  = var.loki.promtail.extra_scrape_configs
    extra_label_configs   = var.loki.promtail.extra_label_configs
    extra_pipeline_stages = var.loki.promtail.extra_pipeline_stages
    ignored_containers    = var.loki.promtail.ignored_containers
    ignored_namespaces    = var.loki.promtail.ignored_namespaces
  }

  # Prometheus Configurations
  prometheus_ingress = {
    enabled     = var.prometheus.ingress.enabled
    type        = var.prometheus.ingress.type
    public      = var.prometheus.ingress.public
    tls_enabled = var.prometheus.ingress.tls_enabled

    annotations = var.prometheus.ingress.additional_annotations
    hosts       = var.prometheus.ingress.hosts
    path        = var.prometheus.ingress.path
  }




  # Grafana Configurations
  cloudwatch_policies = [
    {
      actions = [
        "cloudwatch:DescribeAlarmsForMetric",
        "cloudwatch:DescribeAlarmHistory",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:ListMetrics",
        "cloudwatch:GetMetricData",
        "cloudwatch:GetInsightRuleReport"
      ],
      resources = ["*"]
    },
    {
      actions   = ["ec2:DescribeTags", "ec2:DescribeInstances", "ec2:DescribeRegions"],
      resources = ["*"]
    },
    {
      actions   = ["tag:GetResources"],
      resources = ["*"]
    },
    {
      actions   = ["pi:GetResourceMetrics"],
      resources = ["*"]
    },
    {
      actions = [
        "logs:DescribeLogGroups",
        "logs:GetLogGroupFields",
        "logs:StartQuery",
        "logs:StopQuery",
        "logs:GetQueryResults",
        "logs:GetLogEvents"
      ],
      resources = ["*"]
    },
  ]

  grafana_service_account = {
    name   = var.grafana.service_account.name
    enable = var.grafana.service_account.enable
    annotations = merge(var.grafana.service_account.annotations,
      {
        "eks.amazonaws.com/role-arn" : try(module.grafana_cloudwatch_role.arn, "")
      }
    )
  }

  grafana_datasources = concat([{
    type        = "cloudwatch"
    name        = "Cloudwatch"
    access_mode = "proxy"
    uid         = "cloudwatch"
    encoded_json = jsonencode({
      authType      = "default"
      defaultRegion = data.aws_region.current.name
    })
    is_default = false
  }], var.grafana.datasources)

  grafana_ingress = {
    annotations = merge(var.grafana.ingress.additional_annotations, length(var.grafana.ingress.alb_certificate) > 0 ? { "alb.ingress.kubernetes.io/certificate-arn" = var.grafana.ingress.alb_certificate } : {})
    hosts       = var.grafana.ingress.hosts
    path        = var.grafana.ingress.path
    path_type   = var.grafana.ingress.path_type
    type        = var.grafana.ingress.type
    public      = var.grafana.ingress.public
    tls_enabled = var.grafana.ingress.tls_enabled
  }

}
