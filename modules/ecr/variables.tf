variable "repository_names" {
  description = "ECR repository names (one per microservice)."
  type        = set(string)
}

variable "image_tag_mutability" {
  description = "MUTABLE allows retagging; IMMUTABLE enforces digest-only promotion for prod tags."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Enable basic ECR image scanning on push."
  type        = bool
  default     = true
}

variable "keep_last_tagged_images" {
  description = "Number of tagged images to retain per repository (rollback window)."
  type        = number
  default     = 30
}

variable "untagged_image_expiry_days" {
  description = "Days before untagged layers are expired."
  type        = number
  default     = 7
}

variable "force_delete" {
  description = "Allow repository deletion even when images exist (non-prod bootstrap only)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags applied to ECR repositories."
  type        = map(string)
  default     = {}
}
