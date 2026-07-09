output "db_secret_arns" {
  description = "Map of environment to DB credentials secret ARN."
  value       = { for env, secret in aws_secretsmanager_secret.db : env => secret.arn }
}

output "db_secret_names" {
  description = "Map of environment to DB credentials secret name."
  value       = { for env, secret in aws_secretsmanager_secret.db : env => secret.name }
}

output "jenkins_slack_secret_arn" {
  description = "ARN of Slack webhook secret."
  value       = aws_secretsmanager_secret.jenkins_webhook.arn
}

output "sonarqube_token_secret_arn" {
  description = "ARN of SonarQube token secret."
  value       = aws_secretsmanager_secret.sonarqube_token.arn
}

output "snyk_token_secret_arn" {
  description = "ARN of Snyk token secret."
  value       = aws_secretsmanager_secret.snyk_token.arn
}
