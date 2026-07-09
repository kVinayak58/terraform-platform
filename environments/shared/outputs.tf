output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  value = var.aws_region
}

output "ecr_repository_urls" {
  description = "ECR URLs keyed by repository name."
  value       = module.ecr.repository_urls
}

output "artifacts_bucket_name" {
  value = module.artifacts.bucket_id
}

output "artifacts_bucket_arn" {
  value = module.artifacts.bucket_arn
}

output "jenkins_ci_role_arn" {
  description = "Configure in Jenkins: AWS Credentials via OIDC → this role."
  value       = module.iam_jenkins.ci_role_arn
}

output "jenkins_cd_role_arn" {
  description = "Use for deploy/rollback stages (pull-only + S3 read)."
  value       = module.iam_jenkins.cd_role_arn
}

output "db_secret_names" {
  description = "Populate secret values via AWS CLI or console before first deploy."
  value       = module.secrets.db_secret_names
}

output "jenkins_slack_secret_name" {
  value = "shopeasy/jenkins/slack-webhook"
}

output "promotion_s3_prefix" {
  description = "Jenkins uploads promotion manifests here for rollback (ADR-003 Layer 2)."
  value       = "s3://${module.artifacts.bucket_id}/promotions/{service}/{env}/"
}

output "rollback_commands" {
  description = "Quick reference for incident response."
  value       = <<-EOT
    Layer 1 (Helm):  helm rollback <release> <rev> -n shopeasy-<env> --wait
    Layer 2 (Digest): aws s3 cp s3://${module.artifacts.bucket_id}/promotions/<svc>/<env>/latest.json -
                      then helm upgrade with image.digest from manifest
  EOT
}

output "cloudwatch_service_log_groups" {
  value = module.cloudwatch.service_log_group_names
}
