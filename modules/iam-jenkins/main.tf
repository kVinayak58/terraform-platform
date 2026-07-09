locals {
  oidc_host = replace(var.jenkins_oidc_provider_url, "https://", "")
}

resource "aws_iam_openid_connect_provider" "jenkins" {
  url = var.jenkins_oidc_provider_url

  client_id_list = [var.jenkins_oidc_audience]

  # Thumbprint must match Jenkins TLS cert chain. Replace after Jenkins is provisioned.
  # Default below is Amazon Root CA 1 — common for ACM-terminated endpoints.
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]

  tags = merge(var.tags, {
    Name = "${var.project_name}-jenkins-oidc"
  })
}

data "aws_iam_policy_document" "jenkins_ecr_push" {
  statement {
    sid    = "ECRAuth"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPushPull"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages",
      "ecr:ListImages",
    ]
    resources = var.ecr_repository_arns
  }

  dynamic "statement" {
    for_each = var.artifacts_bucket_arn != null ? [1] : []
    content {
      sid    = "ArtifactsUpload"
      effect = "Allow"
      actions = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
      ]
      resources = [
        var.artifacts_bucket_arn,
        "${var.artifacts_bucket_arn}/*",
      ]
    }
  }

  dynamic "statement" {
    for_each = length(var.kms_key_arns) > 0 ? [1] : []
    content {
      sid    = "CosignSign"
      effect = "Allow"
      actions = [
        "kms:Sign",
        "kms:GetPublicKey",
        "kms:DescribeKey",
      ]
      resources = var.kms_key_arns
    }
  }

  dynamic "statement" {
    for_each = length(var.secrets_manager_arns) > 0 ? [1] : []
    content {
      sid    = "SecretsRead"
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
      ]
      resources = var.secrets_manager_arns
    }
  }
}

resource "aws_iam_policy" "jenkins_ci" {
  name        = "${var.project_name}-jenkins-ci"
  description = "Allows Jenkins CI to push images to ShopEasy ECR and upload artifacts."
  policy      = data.aws_iam_policy_document.jenkins_ecr_push.json

  tags = var.tags
}

data "aws_iam_policy_document" "jenkins_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.jenkins.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = [var.jenkins_oidc_audience]
    }

    condition {
      test     = "StringLike"
      variable = "${local.oidc_host}:sub"
      values   = var.jenkins_allowed_subjects
    }
  }
}

resource "aws_iam_role" "jenkins_ci" {
  name               = "${var.project_name}-jenkins-ci"
  assume_role_policy = data.aws_iam_policy_document.jenkins_assume_role.json

  tags = merge(var.tags, {
    Name = "${var.project_name}-jenkins-ci"
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_ci" {
  role       = aws_iam_role.jenkins_ci.name
  policy_arn = aws_iam_policy.jenkins_ci.arn
}

# Read-only role for CD deploy agents (Helm apply, ECR pull only — no push).
data "aws_iam_policy_document" "jenkins_cd" {
  statement {
    sid    = "ECRAuth"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPull"
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:DescribeImages",
    ]
    resources = var.ecr_repository_arns
  }

  dynamic "statement" {
    for_each = var.artifacts_bucket_arn != null ? [1] : []
    content {
      sid    = "ArtifactsRead"
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:ListBucket",
      ]
      resources = [
        var.artifacts_bucket_arn,
        "${var.artifacts_bucket_arn}/*",
      ]
    }
  }
}

resource "aws_iam_policy" "jenkins_cd" {
  name        = "${var.project_name}-jenkins-cd"
  description = "Allows Jenkins CD to pull images and read promotion manifests for rollback."
  policy      = data.aws_iam_policy_document.jenkins_cd.json

  tags = var.tags
}

data "aws_iam_policy_document" "jenkins_cd_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.jenkins.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = [var.jenkins_oidc_audience]
    }

    condition {
      test     = "StringLike"
      variable = "${local.oidc_host}:sub"
      values   = var.jenkins_allowed_subjects
    }
  }
}

resource "aws_iam_role" "jenkins_cd" {
  name               = "${var.project_name}-jenkins-cd"
  assume_role_policy = data.aws_iam_policy_document.jenkins_cd_assume.json

  tags = merge(var.tags, {
    Name = "${var.project_name}-jenkins-cd"
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_cd" {
  role       = aws_iam_role.jenkins_cd.name
  policy_arn = aws_iam_policy.jenkins_cd.arn
}
