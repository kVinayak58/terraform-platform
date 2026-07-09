resource "aws_secretsmanager_secret" "db" {
  for_each = var.environments

  name                    = "${var.project_name}/${each.value}/db-credentials"
  description             = "PostgreSQL credentials for ShopEasy ${each.value}"
  recovery_window_in_days = var.recovery_window_days

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${each.value}-db"
    Environment = each.value
  })
}

resource "aws_secretsmanager_secret" "jenkins_webhook" {
  name                    = "${var.project_name}/jenkins/slack-webhook"
  description             = "Slack webhook URL for Jenkins notifications (rotate via console/CLI)"
  recovery_window_in_days = var.recovery_window_days

  tags = merge(var.tags, {
    Name = "${var.project_name}-jenkins-slack"
  })
}

resource "aws_secretsmanager_secret" "sonarqube_token" {
  name                    = "${var.project_name}/jenkins/sonarqube-token"
  description             = "SonarQube token for CI scans"
  recovery_window_in_days = var.recovery_window_days

  tags = merge(var.tags, {
    Name = "${var.project_name}-sonarqube-token"
  })
}

resource "aws_secretsmanager_secret" "snyk_token" {
  name                    = "${var.project_name}/jenkins/snyk-token"
  description             = "Snyk API token for dependency scanning"
  recovery_window_in_days = var.recovery_window_days

  tags = merge(var.tags, {
    Name = "${var.project_name}-snyk-token"
  })
}
