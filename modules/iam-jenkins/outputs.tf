output "oidc_provider_arn" {
  description = "ARN of the Jenkins OIDC identity provider."
  value       = aws_iam_openid_connect_provider.jenkins.arn
}

output "ci_role_arn" {
  description = "IAM role ARN for Jenkins CI (build, scan, push, sign)."
  value       = aws_iam_role.jenkins_ci.arn
}

output "ci_role_name" {
  description = "IAM role name for Jenkins CI."
  value       = aws_iam_role.jenkins_ci.name
}

output "cd_role_arn" {
  description = "IAM role ARN for Jenkins CD (pull, deploy, rollback)."
  value       = aws_iam_role.jenkins_cd.arn
}

output "cd_role_name" {
  description = "IAM role name for Jenkins CD."
  value       = aws_iam_role.jenkins_cd.name
}
