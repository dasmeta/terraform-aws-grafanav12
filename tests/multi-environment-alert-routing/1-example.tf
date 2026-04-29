module "this" {
  source = "../.."

  cluster_name = local.eks_cluster_name
  name_prefix  = "multi-env-routing"

  deploy_grafana_stack_dashboard = false
  application_dashboard = [{
    name = "multi-env-routing-dashboard"
    rows = [
      { type = "block/service", name = "http-echo", alerts = { namespaces = local.app_namespaces } }
    ]
    data_source = {
      uid = "prometheus"
    }
    variables = [
      {
        name    = "namespace"
        options = [for namespace in local.app_namespaces : { value = namespace }]
      }
    ]
  }]

  alerts = {
    rules = [
      {
        datasource  = "prometheus"
        equation    = "gt"
        expr        = "sum(increase(kube_pod_container_status_restarts_total[3m]))"
        folder_name = "Total Pod Restarts"
        function    = "mean"
        name        = "Total Pod Restarts"
        labels = {
          priority = "P1"
        }
        threshold      = 5
        summary        = "custom alert for total pod restarts validation"
        no_data_state  = "OK"
        exec_err_state = "OK"
      },
    ]
    contact_points = {
      slack = [
        {
          name        = "Slack-dev"
          webhook_url = var.slack_webhook_url
          recipient   = "#test-webhooks-channel-dev"
        },
        {
          name        = "Slack-stage"
          webhook_url = var.slack_webhook_url
          recipient   = "#test-webhooks-channel-stage"
        },
        {
          name        = "Slack-prod"
          webhook_url = var.slack_webhook_url
          recipient   = "#test-webhooks-channel-prod"
        },
        {
          name        = "ops-fallback"
          webhook_url = var.slack_webhook_url
          recipient   = "#test-webhooks-channel"
        }
      ]
    }
    notifications = {
      contact_point = "ops-fallback"
      policies = [
        {
          contact_point = "Slack-dev"
          matchers = [{
            label = "env"
            match = "="
            value = "dev"
          }]
        },
        {
          contact_point = "Slack-stage"
          matchers = [{
            label = "env"
            match = "="
            value = "stage"
          }]
        },
        {
          contact_point = "Slack-prod"
          matchers = [{
            label = "env"
            match = "="
            value = "prod"
          }]
        }
      ]
    }
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

  grafana_admin_password = "admin"

  depends_on = [module.eks]
}
