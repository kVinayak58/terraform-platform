output "eks_cluster_log_group_name" {
  description = "Log group for EKS control plane / cluster logs."
  value       = aws_cloudwatch_log_group.eks_cluster.name
}

output "jenkins_log_group_name" {
  description = "Log group for Jenkins controller and agents."
  value       = aws_cloudwatch_log_group.jenkins.name
}

output "service_log_group_names" {
  description = "Map of env/service to CloudWatch log group name."
  value       = { for key, lg in aws_cloudwatch_log_group.service : key => lg.name }
}
