variable "cluster_name" { type = string }
variable "oidc_provider_arn" { type = string }
variable "cluster_oidc_issuer_url" { type = string }
variable "alb_policy_json_path" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
