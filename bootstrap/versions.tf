terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Bootstrap intentionally uses LOCAL state.
  # After this apply, migrate other stacks to the S3 backend this module creates.
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "shopeasy"
      ManagedBy   = "terraform"
      Component   = "state-bootstrap"
      Environment = "shared"
    }
  }
}
