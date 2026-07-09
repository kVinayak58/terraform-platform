terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      ManagedBy   = "terraform"
      Environment = "platform"
      Layer       = "compute"
    }
  }
}

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name

  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name

  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

locals {
  namespaces = [
    "shopeasy-dev",
    "shopeasy-qa",
    "shopeasy-uat",
    "shopeasy-prod",
  ]
}

module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  cluster_name = var.cluster_name
  tags         = { Project = var.project_name }
}

module "eks" {
  source = "../../modules/eks"

  cluster_name         = var.cluster_name
  cluster_version      = var.cluster_version
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnets
  node_instance_types  = var.node_instance_types
  node_desired_size    = var.node_desired_size
  node_min_size        = var.node_min_size
  node_max_size        = var.node_max_size

  tags = { Project = var.project_name }
}

module "alb_controller_iam" {
  source = "../../modules/alb-controller-iam"

  cluster_name            = module.eks.cluster_name
  oidc_provider_arn       = module.eks.oidc_provider_arn
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  alb_policy_json_path    = "${path.module}/../../policies/alb-controller-iam-policy.json"

  tags = { Project = var.project_name }
}

module "namespaces" {
  source = "../../modules/k8s-namespaces"

  project_name = var.project_name
  namespaces   = local.namespaces

  depends_on = [module.eks]
}
