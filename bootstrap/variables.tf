variable "aws_region" {
  description = "AWS region for the Terraform state bucket and lock table."
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform remote state."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.state_bucket_name))
    error_message = "Bucket name must be 3-63 chars, lowercase, DNS-compliant."
  }
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking."
  type        = string
  default     = "shopeasy-terraform-locks"
}

variable "kms_key_alias" {
  description = "Alias for the KMS key encrypting Terraform state objects."
  type        = string
  default     = "alias/shopeasy-terraform-state"
}

variable "state_retention_days" {
  description = "Noncurrent state object expiration (days). 0 disables lifecycle expiration."
  type        = number
  default     = 90
}
