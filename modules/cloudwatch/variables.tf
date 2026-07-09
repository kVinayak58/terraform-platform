variable "project_name" {
  description = "Project prefix for log group names."
  type        = string
  default     = "shopeasy"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 30
}

variable "services" {
  description = "Microservice names for per-service log groups."
  type        = set(string)
  default = [
    "frontend",
    "product-service",
    "order-service",
    "payment-service",
    "inventory-service",
    "notification-service",
  ]
}

variable "environments" {
  description = "Environments receiving dedicated log group prefixes."
  type        = set(string)
  default     = ["dev", "qa", "uat", "prod"]
}

variable "tags" {
  description = "Additional tags for log groups."
  type        = map(string)
  default     = {}
}
