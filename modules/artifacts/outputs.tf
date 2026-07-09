output "bucket_id" {
  description = "Artifacts bucket name."
  value       = aws_s3_bucket.artifacts.id
}

output "bucket_arn" {
  description = "Artifacts bucket ARN (for IAM policies)."
  value       = aws_s3_bucket.artifacts.arn
}
