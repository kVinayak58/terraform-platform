resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.project_name}/cluster"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.project_name}-eks-cluster"
  })
}

resource "aws_cloudwatch_log_group" "jenkins" {
  name              = "/${var.project_name}/jenkins"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.project_name}-jenkins"
  })
}

resource "aws_cloudwatch_log_group" "service" {
  for_each = {
    for pair in setproduct(var.environments, var.services) :
    "${pair[0]}/${pair[1]}" => {
      environment = pair[0]
      service     = pair[1]
    }
  }

  name              = "/${var.project_name}/${each.value.environment}/${each.value.service}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${each.value.environment}-${each.value.service}"
    Environment = each.value.environment
    Service     = each.value.service
  })
}

resource "aws_cloudwatch_log_metric_filter" "service_errors" {
  for_each = aws_cloudwatch_log_group.service

  name           = "${replace(each.key, "/", "-")}-errors"
  log_group_name = each.value.name
  pattern        = "?ERROR ?Exception ?CRITICAL"

  metric_transformation {
    name      = "${var.project_name}-${replace(each.key, "/", "-")}-errors"
    namespace = "ShopEasy/Application"
    value     = "1"
    unit      = "Count"
  }
}
