output "aws_account_id" {
  description = "AWS account hosting ShopEasy platform resources."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "Region where state infrastructure was created."
  value       = var.aws_region
}

output "state_bucket_name" {
  description = "S3 bucket for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "ARN of the Terraform state bucket."
  value       = aws_s3_bucket.terraform_state.arn
}

output "lock_table_name" {
  description = "DynamoDB table for Terraform state locking."
  value       = aws_dynamodb_table.terraform_locks.name
}

output "lock_table_arn" {
  description = "ARN of the Terraform lock table."
  value       = aws_dynamodb_table.terraform_locks.arn
}

output "kms_key_arn" {
  description = "KMS key ARN used to encrypt state objects."
  value       = aws_kms_key.terraform_state.arn
}

output "backend_config_snippet" {
  description = "Paste into environment backend.tf files (Step 2)."
  value       = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.terraform_state.id}"
        key            = "<ENV>/terraform.tfstate"
        region         = "${var.aws_region}"
        dynamodb_table = "${aws_dynamodb_table.terraform_locks.name}"
        encrypt        = true
        kms_key_id     = "${aws_kms_key.terraform_state.arn}"
      }
    }
  EOT
}
