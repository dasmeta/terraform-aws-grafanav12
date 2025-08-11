module "this" {
  source = "../.."

  name         = "Test-dashboard"
  cluster_name = "eks-dev"

  application_dashboard = {
    rows : [
      { type : "block/sla", sla_ingress_type = "alb", load_balancer_arn = "load_balancer_arn", datasource_uid = "cloudwatch", region = "us-east-2" },
      { type : "block/alb_ingress", load_balancer_arn = "load_balancer_arn", region : "us-east-2" },
      { type : "block/service", name = "worker", show_err_logs = true },
      { type : "block/cloudwatch", region : "us-east-2" }
    ]
    data_source = {
      uid : "cloudwatch"
    }
    variables = [
      {
        "name" : "namespace",
        "options" : [
          {
            "value" : "prod"
          },
          {
            "selected" : true,
            "value" : "dev"
          }
        ],
      }
    ]
  }
  alerts = {
    rules = [
      {
        "datasource" : "prometheus",
        "equation" : "gt",
        "expr" : "avg(increase(nginx_ingress_controller_request_duration_seconds_sum[3m])) / 10",
        "folder_name" : "Nginx Alerts",
        "function" : "mean",
        "name" : "Latency P1",
        "labels" : {
          "priority" : "P1",
        }
        "threshold" : 3

        # we override no-data/exec-error state for this example/test only, it is supposed this values will not be set here so they get their default ones
        "no_data_state" : "OK"
        "exec_err_state" : "OK"
        # "exec_err_state" : "Alerting" # uncomment to trigger new alert
      },
      {
        "datasource" : "prometheus",
        "equation" : "gt",
        "expr" : "avg(increase(nginx_ingress_controller_request_duration_seconds_sum[3m])) / 10",
        "folder_name" : "Nginx Alerts",
        "function" : "mean",
        "name" : "Latency P2",
        "labels" : {
          "priority" : "P2",
        }
        "threshold" : 3

        # we override no-data/exec-error state for this example/test only, it is supposed this values will not be set here so they get their default ones
        "no_data_state" : "OK"
        "exec_err_state" : "OK"
        # "exec_err_state" : "Alerting" # uncomment to trigger new alert
      }
    ]
  }

  grafana = {

    resources = {
      request = {
        cpu = "1"
        mem = "1Gi"
      }
    }
    ingress = {
      type            = "alb"
      tls_enabled     = true
      public          = true
      alb_certificate = "cert_arn"

      hosts = ["grafana.example.com"]
      additional_annotations = {
        "alb.ingress.kubernetes.io/group.name" = "dev-ingress"
      }
    }
    datasources = [{ type = "cloudwatch", name = "Cloudwatch" }]

  }

  tempo = {
    enabled = true

    metrics_generator = {
      enabled = true
    }
    enable_service_monitor = true

    persistence = {
      enabled = true
      size    = "10Gi"
    }
  }

  loki = {
    enabled = true

    ingress = {
      enabled = true
      hosts   = ["loki.example.com"]
      additional_annotations = {
        "alb.ingress.kubernetes.io/certificate-arn" = "cert_arn"
        "alb.ingress.kubernetes.io/group.name"      = "dev-ingress"
      }
    }

    promtail = {
      log_format         = "json"
      ignored_containers = ["kube-system"]

    }

  }

  prometheus = {
    enabled = true

    ingress = {
      enabled = true
      hosts   = ["prometheus.example.com"]
      additional_annotations = {
        "alb.ingress.kubernetes.io/certificate-arn" = "cert_arn"
        "alb.ingress.kubernetes.io/group.name"      = "dev-ingress"
      }
      path_type = "Prefix"
    }
  }
  grafana_admin_password = "admin"
  # dashboards_json_files = [
  #   "./dashboard_files/ALB_dashboard.json",
  #   "./dashboard_files/Application_main_dashboard.json"
  # ]
}
