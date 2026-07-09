variable "bucket_name" {
  description = "Globally unique S3 bucket for SBOMs, promotion manifests, and rollback history."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for bucket encryption (optional; uses SSE-S3 if null)."
  type        = string
  default     = null
}

variable "noncurrent_version_expiration_days" {
  description = "Days to retain noncurrent promotion manifest versions."
  type        = number
  default     = 365
}

variable "tags" {
  description = "Additional tags for the artifacts bucket."
  type        = map(string)
  default     = {}
}
