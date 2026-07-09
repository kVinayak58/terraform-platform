terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
      Environment = "shared"
      Layer       = "platform"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  ecr_repositories = toset([
    "shopeasy-frontend",
    "shopeasy-product-service",
    "shopeasy-order-service",
    "shopeasy-payment-service",
    "shopeasy-inventory-service",
    "shopeasy-notification-service",
  ])

  common_tags = {
    Project = var.project_name
  }
}

module "artifacts" {
  source = "../../modules/artifacts"

  bucket_name = var.artifacts_bucket_name
  tags        = local.common_tags
}

module "ecr" {
  source = "../../modules/ecr"

  repository_names        = local.ecr_repositories
  image_tag_mutability    = var.ecr_image_tag_mutability
  keep_last_tagged_images = var.ecr_keep_last_tagged_images
  force_delete            = var.ecr_force_delete

  tags = local.common_tags
}

module "secrets" {
  source = "../../modules/secrets"

  project_name         = var.project_name
  environments         = toset(var.environments)
  recovery_window_days = var.secrets_recovery_window_days

  tags = local.common_tags
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  project_name       = var.project_name
  log_retention_days = var.log_retention_days
  services           = toset(var.services)
  environments       = toset(var.environments)

  tags = local.common_tags
}

module "iam_jenkins" {
  source = "../../modules/iam-jenkins"

  project_name              = var.project_name
  jenkins_oidc_provider_url = var.jenkins_oidc_provider_url
  jenkins_oidc_audience     = var.jenkins_oidc_audience
  jenkins_allowed_subjects  = var.jenkins_allowed_subjects
  ecr_repository_arns       = values(module.ecr.repository_arns)
  artifacts_bucket_arn      = module.artifacts.bucket_arn
  secrets_manager_arns = [
    module.secrets.jenkins_slack_secret_arn,
    module.secrets.sonarqube_token_secret_arn,
    module.secrets.snyk_token_secret_arn,
  ]

  tags = local.common_tags
}
