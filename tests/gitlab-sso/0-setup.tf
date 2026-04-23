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
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }
  }
}

# set the following env: `export TF_VAR_gitlab_client_id=your_gitlab_client_id` and `export TF_VAR_gitlab_client_secret=your_gitlab_client_secret`
variable "gitlab_client_id" {
  type        = string
  description = "GitLab OAuth application client ID"
  sensitive   = true
}

variable "gitlab_client_secret" {
  type        = string
  description = "GitLab OAuth application client secret"
  sensitive   = true
}

# to customize the grafana hostname and admin password set the following env: `export TF_VAR_grafana_hostname=your_grafana_hostname` and `export TF_VAR_grafana_admin_password=your_grafana_admin_password`
variable "grafana_hostname" {
  type        = string
  description = "Grafana hostname for ingress and provider URL"
  default     = "grafana-sso-test.devops.dasmeta.com"
}

variable "grafana_admin_password" {
  type        = string
  description = "Grafana admin password"
  default     = "admin"
  sensitive   = true
}

locals {
  region           = "eu-central-1"
  eks_cluster_name = "eks-for-grafana-sso-test"
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
  alarms                          = { enabled = false }
  fluent_bit_configs              = { enabled = false }
  nginx_ingress_controller_config = { enabled = false }
  keda                            = { enabled = false }
  linkerd                         = { enabled = false }
  kyverno                         = { enabled = false }

  # enabled components
  enable_ebs_driver            = true
  karpenter                    = { enabled = true }
  alb_load_balancer_controller = { enabled = true }
  external_dns                 = { enabled = true }
}

# the grafana will be created after eks creation, here we create provider for it which will be used to create resources in grafana
provider "grafana" {
  url  = "http://${var.grafana_hostname}"
  auth = "admin:${var.grafana_admin_password}"
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
