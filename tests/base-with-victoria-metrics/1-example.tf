module "this" {
  source = "../.."

  cluster_name = local.eks_cluster_name

  deploy_grafana_stack_dashboard = false
  application_dashboard = [{
    name = "Test-dashboard"
    defaults = {
      cloudwatch = {
        region            = local.region
        load_balancer_arn = data.aws_lb.this.arn
      }
    }
    rows : [
      { type = "block/sla", sla_ingress_type = "alb" },
      { type = "block/alb_ingress" },
      { type = "block/cloudwatch" },
      { type = "block/service", name = "http-echo" },
    ]
    data_source = {
      uid : "prometheus"
    }
    variables = [
      {
        "name" : "namespace",
        "options" : [for namespace in local.app_namespaces : { value = namespace }]
        # [
        #   {
        #     "selected" : true,
        #     "value" : "dev"
        #   },
        #   {
        #     "value" : "stage"
        #   },
        #   {
        #     "value" : "prod"
        #   }
        # ],
      }
    ]
  }]

  alerts = {
    disk_capacity = {
      datasource      = "victoriametrics"
      datasource_type = "prometheus"
      namespace       = "prod|stage"
      threshold       = 85
      pending_period  = "10m"
      labels = {
        priority = "P2"
      }
      annotations = {
        summary = "PVC disk usage is above threshold"
      }
    }
    rules = [
      {
        datasource      = "victoriametrics"
        datasource_type = "prometheus"
        equation        = "gt"
        expr            = "sum(increase(kube_pod_container_status_restarts_total[5m]))"
        folder_name     = "Workload Alerts"
        function        = "mean"
        interval_ms     = 1000
        name            = "Pod Restart Burst"
        pending_period  = "5m"
        labels = {
          priority = "P2"
        }
        threshold      = 5
        no_data_state  = "OK"
        exec_err_state = "OK"
      },
      {
        datasource      = "loki"
        datasource_type = "loki"
        equation        = "gt"
        expr            = "count_over_time({namespace=\"teamplus\", pod=~\"teamplus-main-scheduler.*\"} |= \"Signing-key ring unhealthy\" [30m])"
        folder_name     = "Log Alerts"
        function        = "last"
        interval_ms     = 1000
        name            = "Signing-key ring unhealthy"
        pending_period  = "5m"
        condition       = "$B > 0"
        labels = {
          priority = "P2"
        }
        threshold      = 0
        no_data_state  = "OK"
        exec_err_state = "OK"
      }
    ]
  }

  grafana = {
    resources = {
      requests = {
        cpu    = "1"
        memory = "500Mi"
      }
    }
    ingress = {
      type        = "alb"
      tls_enabled = false
      public      = true

      hosts = [local.grafana_domain_name]
      additional_annotations = {
        "alb.ingress.kubernetes.io/group.name"         = local.eks_cluster_name
        "alb.ingress.kubernetes.io/load-balancer-name" = local.eks_cluster_name
      }
    }
  }

  tempo = {
    enabled = true
  }

  loki_stack = {
    enabled = true
    loki = {
      resources = {
        requests = {
          memory = "1Gi"
        }
      }
    }
  }

  prometheus = {
    enabled = true
    resources = {
      requests = {
        cpu    = "500m"
        memory = "1Gi"
      }
    }
    extra_configs = {
      server = {
        priorityClassName = "high"
      }
    }
  }

  victoria_metrics = {
    enabled = true
  }

  grafana_admin_password = "admin"

  ## can be used to create dashboards based on ready json configuration files
  # dashboards_json_files = [
  #   "./dashboard_files/ALB_dashboard.json",
  #   "./dashboard_files/Application_main_dashboard.json"
  # ]

  depends_on = [module.eks]
}
