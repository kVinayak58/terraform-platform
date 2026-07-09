output "repository_urls" {
  description = "Map of repository name to ECR URL."
  value       = { for name, repo in aws_ecr_repository.this : name => repo.repository_url }
}

output "repository_arns" {
  description = "Map of repository name to ARN (for IAM policies)."
  value       = { for name, repo in aws_ecr_repository.this : name => repo.arn }
}

output "registry_id" {
  description = "AWS account ID of the ECR registry."
  value       = values(aws_ecr_repository.this)[0].registry_id
}
