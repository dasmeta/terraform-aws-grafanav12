locals {

  # General configurations
  eks_oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}"
  s3_aws_policies = [
    {
      actions = ["s3:ListBucket"],
      resources = concat(
        var.loki_stack.enabled ? ["arn:aws:s3:::${local.loki_s3_bucket_name}"] : [],
        var.tempo.enabled ? ["arn:aws:s3:::${local.tempo_s3_bucket_name}"] : []
      )
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
      resources = concat(
        var.loki_stack.enabled ? ["arn:aws:s3:::${local.loki_s3_bucket_name}/*"] : [],
        var.tempo.enabled ? ["arn:aws:s3:::${local.tempo_s3_bucket_name}/*"] : []
      )
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
        "eks.amazonaws.com/role-arn" : try(module.s3_eks_role[0].arn, "")
      }
    )
  }

  # Loki configurations
  loki_s3_bucket_name = length(var.loki_stack.send_logs_s3.bucket_name) > 0 ? var.loki_stack.send_logs_s3.bucket_name : "loki-logs-${var.cluster_name}-${random_string.random.result}"
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
        "eks.amazonaws.com/role-arn" : try(module.grafana_cloudwatch_role[0].arn, "")
      }
    )
  }

  grafana_datasources = concat(
    [{
      type        = "cloudwatch"
      name        = "Cloudwatch"
      access_mode = "proxy"
      uid         = "cloudwatch"
      encoded_json = jsonencode({
        authType      = "default"
        defaultRegion = data.aws_region.current.name
      })
      is_default = false
    }],
    var.grafana.datasources
  )

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

# EKS cluster level components monitoring
locals {
  karpenter_monitoring = var.eks_monitoring.karpenter

  karpenter_scrape_enabled = local.karpenter_monitoring.enabled && local.karpenter_monitoring.scrape.enabled
  karpenter_scrape_config = {
    job_name              = local.karpenter_monitoring.service_name
    kubernetes_sd_configs = [{ role = "endpoints" }]
    relabel_configs = [
      { action = "keep", source_labels = ["__meta_kubernetes_namespace", "__meta_kubernetes_service_name", "__meta_kubernetes_endpoint_port_name"], regex = "${local.karpenter_monitoring.namespace};${local.karpenter_monitoring.service_name};${local.karpenter_monitoring.scrape.port}" },
      { action = "replace", source_labels = ["__meta_kubernetes_namespace"], target_label = "namespace" },
      { action = "replace", source_labels = ["__meta_kubernetes_pod_name"], target_label = "pod" },
    ]
  }
  # the scrape config goes to the active metrics collector only, a caller provided job with the same name wins
  prometheus_karpenter_scrape_configs       = local.karpenter_scrape_enabled && var.metrics_collector == "prometheus" && !contains([for job in try(concat(var.prometheus.additional_scrape_configs, []), []) : try(job.job_name, "")], local.karpenter_monitoring.service_name) ? [local.karpenter_scrape_config] : []
  victoria_metrics_karpenter_scrape_configs = local.karpenter_scrape_enabled && var.metrics_collector == "victoria_metrics" && !contains([for job in try(concat(var.victoria_metrics.agent.extra_scrape_configs, []), []) : try(job.job_name, "")], local.karpenter_monitoring.service_name) ? [local.karpenter_scrape_config] : []

  karpenter_dashboard_enabled = local.karpenter_monitoring.enabled && local.karpenter_monitoring.dashboard.enabled
  # the dashboard reuses the folder if the grafana stack already created it for other dashboards/alerts, otherwise creates its own
  karpenter_dashboard_folder_uids = { for name, uid in module.this.folder_uids : name => uid if name == local.karpenter_monitoring.dashboard.folder_name }
  karpenter_dashboard_rows = [
    merge(
      {
        type          = "block/service"
        block_name    = "Karpenter controller service state (kubernetes native metrics)"
        name          = "controller" # karpenter container name, used for cpu/memory/restarts
        workload_name = "karpenter"  # karpenter deployment name, used for replicas/network/logs
        namespace     = local.karpenter_monitoring.namespace
        disk_widgets  = { enabled = false }
      },
      local.karpenter_monitoring.dashboard.service,
      {
        alerts = provider::deepmerge::mergo(
          {
            map_namespace_to_env_label = false                                                             # put karpenter namespace into `namespace` label, `env` label stays for environment routing
            defaults                   = { no_data_state = "OK", group = "Karpenter", stable_uids = true } # no karpenter deployment(cluster without karpenter) is not an issue, controller alerts share the karpenter alerts group, stable_uids keeps rule uids fixed when rules in the group change
            cpu                        = { enabled = false }                                               # karpenter runs without cpu limit so there is nothing to compare usage with
            replicas_no                = { pending_period = "1m" }                                         # the service block fires this on first evaluation(0s), wait a bit to skip short blips
            restarts                   = { pending_period = "2m" }                                         # same for restarts, a single controller restart during upgrade should not page
          },
          local.karpenter_monitoring.alerts.service
        )
      }
    ),
    {
      type       = "block/karpenter"
      block_name = local.karpenter_monitoring.dashboard.karpenter_row_title
      namespace  = local.karpenter_monitoring.namespace
      # interruption widgets/alert are opt-in in the generic block, EKS karpenter handles spot interruptions through its SQS queue so they are on here
      widgets = provider::deepmerge::mergo({ interruption = true }, local.karpenter_monitoring.dashboard.widgets)
      alerts = provider::deepmerge::mergo(
        {
          metrics_scrape           = { job = local.karpenter_monitoring.service_name }
          interruption_not_handled = { enabled = true }
        },
        local.karpenter_monitoring.alerts.karpenter
      )
    },
  ]
}
