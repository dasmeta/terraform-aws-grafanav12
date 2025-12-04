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

  # can be used to create custom/additional alerts
  # alerts = {
  #   rules = [
  #     {
  #       "datasource" : "prometheus",
  #       "equation" : "gt",
  #       "expr" : "avg(increase(nginx_ingress_controller_request_duration_seconds_sum[3m])) / 10",
  #       "folder_name" : "Nginx Alerts",
  #       "function" : "mean",
  #       "name" : "Latency P1",
  #       "labels" : {
  #         "priority" : "P1",
  #       }
  #       "threshold" : 3

  #       # we override no-data/exec-error state for this example/test only, it is supposed this values will not be set here so they get their default ones
  #       "no_data_state" : "OK"
  #       "exec_err_state" : "OK"
  #       # "exec_err_state" : "Alerting" # uncomment to trigger new alert
  #     },
  #     {
  #       "datasource" : "prometheus",
  #       "equation" : "gt",
  #       "expr" : "avg(increase(nginx_ingress_controller_request_duration_seconds_sum[3m])) / 10",
  #       "folder_name" : "Nginx Alerts",
  #       "function" : "mean",
  #       "name" : "Latency P2",
  #       "labels" : {
  #         "priority" : "P2",
  #       }
  #       "threshold" : 3

  #       # we override no-data/exec-error state for this example/test only, it is supposed this values will not be set here so they get their default ones
  #       "no_data_state" : "OK"
  #       "exec_err_state" : "OK"
  #       # "exec_err_state" : "Alerting" # uncomment to trigger new alert
  #     }
  #   ]
  # }

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
  grafana_admin_password = "admin"

  ## can be used to create dashboards based on ready json configuration files
  # dashboards_json_files = [
  #   "./dashboard_files/ALB_dashboard.json",
  #   "./dashboard_files/Application_main_dashboard.json"
  # ]

  depends_on = [module.eks]
}
