variable "aws_region" {
  description = "AWS region for shared platform resources."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix."
  type        = string
  default     = "shopeasy"
}

variable "environments" {
  description = "Logical deployment environments."
  type        = list(string)
  default     = ["dev", "qa", "uat", "prod"]
}

variable "services" {
  description = "Microservice names (without shopeasy- prefix)."
  type        = list(string)
  default = [
    "frontend",
    "product-service",
    "order-service",
    "payment-service",
    "inventory-service",
    "notification-service",
  ]
}

variable "artifacts_bucket_name" {
  description = "Globally unique S3 bucket for SBOMs and promotion/rollback history."
  type        = string
}

variable "ecr_image_tag_mutability" {
  description = "IMMUTABLE recommended for production-grade promotion."
  type        = string
  default     = "IMMUTABLE"
}

variable "ecr_keep_last_tagged_images" {
  description = "Tagged images retained per repo — rollback window."
  type        = number
  default     = 30
}

variable "ecr_force_delete" {
  description = "Allow ECR repo delete with images (lab only)."
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention."
  type        = number
  default     = 30
}

variable "secrets_recovery_window_days" {
  description = "Secrets Manager recovery window (use 30 in prod)."
  type        = number
  default     = 30
}

variable "jenkins_oidc_provider_url" {
  description = "Jenkins OIDC issuer URL. Update after Jenkins is installed."
  type        = string
}

variable "jenkins_oidc_audience" {
  description = "OIDC audience claim expected by AWS STS."
  type        = string
  default     = "sts.amazonaws.com"
}

variable "jenkins_allowed_subjects" {
  description = "Jenkins OIDC sub claim patterns allowed to assume CI/CD roles."
  type        = list(string)
  default     = ["repo:shopeasy/*:*"]
}
