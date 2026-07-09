output "vpc_id" {
  value = module.vpc.vpc_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "alb_controller_role_arn" {
  value = module.alb_controller_iam.role_arn
}

output "namespaces" {
  value = module.namespaces.namespace_names
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
