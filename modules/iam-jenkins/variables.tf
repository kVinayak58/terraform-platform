variable "project_name" {
  description = "Project prefix for IAM resource names."
  type        = string
  default     = "shopeasy"
}

variable "jenkins_oidc_provider_url" {
  description = "Jenkins OIDC issuer URL (no trailing slash). Example: https://jenkins.example.com/oidc."
  type        = string
}

variable "jenkins_oidc_audience" {
  description = "Expected aud claim from Jenkins OIDC tokens."
  type        = string
  default     = "sts.amazonaws.com"
}

variable "jenkins_allowed_subjects" {
  description = "List of sub claim patterns Jenkins may assume. Use repo-scoped subjects in production."
  type        = list(string)
  default     = ["repo:shopeasy/*:*"]
}

variable "ecr_repository_arns" {
  description = "ECR repository ARNs Jenkins CI may push to."
  type        = list(string)
}

variable "artifacts_bucket_arn" {
  description = "S3 bucket ARN for SBOM and promotion manifest uploads."
  type        = string
  default     = null
}

variable "kms_key_arns" {
  description = "KMS key ARNs for Cosign signing (added in pipeline step)."
  type        = list(string)
  default     = []
}

variable "secrets_manager_arns" {
  description = "Secrets Manager ARNs Jenkins CI may read (SonarQube, Snyk, webhooks)."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags for IAM resources."
  type        = map(string)
  default     = {}
}
