variable "project_name" {
  description = "Project prefix for secret names."
  type        = string
  default     = "shopeasy"
}

variable "environments" {
  description = "Environment names that receive isolated secret namespaces."
  type        = set(string)
  default     = ["dev", "qa", "uat", "prod"]
}

variable "recovery_window_days" {
  description = "Days before secret deletion is permanent (0 = immediate, prod use 30)."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags for Secrets Manager resources."
  type        = map(string)
  default     = {}
}
