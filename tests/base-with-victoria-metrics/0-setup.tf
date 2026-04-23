terraform {
  required_version = "~> 1.3"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# the grafana will be created after eks creation, here we create provider for it which will be used to create resources in grafana
provider "grafana" {
  url  = "http://${local.grafana_domain_name}"
  auth = "admin:admin"
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_host
    cluster_ca_certificate = module.eks.cluster_certificate
    token                  = module.eks.cluster_token
  }
}
provider "kubernetes" {
  host                   = module.eks.cluster_host
  cluster_ca_certificate = module.eks.cluster_certificate
  token                  = module.eks.cluster_token
}

provider "aws" {
  region = local.region
}

# Prepare for test
data "aws_availability_zones" "available" {}
data "aws_vpcs" "ids" {
  tags = {
    Name = "default"
  }
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.ids.ids[0]]
  }
}

locals {
  region              = "eu-central-1"
  eks_cluster_name    = "eks-for-grafana-stack-test"
  grafana_domain_name = "grafana-stack-test.devops.dasmeta.com"
  app_namespaces      = ["dev", "stage", "prod"]
  disabled = {
    enabled = false
  }
  enabled = {
    enabled = true
  }
}
# prepare eks setup for grafana-stack components
module "eks" {
  source  = "dasmeta/eks/aws"
  version = "2.24.2"

  cluster_name = local.eks_cluster_name

  vpc = {
    link = {
      id                 = data.aws_vpcs.ids.ids[0]
      private_subnet_ids = data.aws_subnets.subnets.ids
    }
  }

  node_groups = {
    default = {
      desired_size   = 1
      max_size       = 1
      min_size       = 1
      capacity_type  = "SPOT"
      instance_types = ["t3.xlarge"]
    }
  }

  enable_external_secrets         = false
  create_cert_manager             = false
  enable_node_problem_detector    = false
  metrics_exporter                = "disabled"
  alarms                          = local.disabled
  fluent_bit_configs              = local.disabled
  nginx_ingress_controller_config = local.disabled
  keda                            = local.disabled
  linkerd                         = local.disabled
  kyverno                         = local.disabled

  # enabled components
  enable_ebs_driver            = true
  karpenter                    = local.enabled
  alb_load_balancer_controller = local.enabled
  external_dns                 = local.enabled
}

# we deploy same app in two different namespaces: prod and dev to check $namespace variable dashboard
resource "helm_release" "http_echo" {
  for_each = toset(local.app_namespaces)

  name             = "http-echo"
  repository       = "https://dasmeta.github.io/helm"
  chart            = "base"
  version          = "0.3.15"
  namespace        = each.value
  create_namespace = true
  wait             = true

  values = [
    file("${path.module}/http-echo.yaml"),
    <<-EOT
    ingress:
      annotations:
        alb.ingress.kubernetes.io/group.name: ${local.eks_cluster_name}
        alb.ingress.kubernetes.io/load-balancer-name: ${local.eks_cluster_name}
      hosts:
        - host: http-echo.${local.grafana_domain_name}
          paths:
            - path: "/${each.value}"
    EOT
  ]

  depends_on = [module.eks]
}

data "aws_lb" "this" {
  name = local.eks_cluster_name

  depends_on = [helm_release.http_echo]
}
