resource "aws_cloudwatch_log_group" "services" {
  for_each = var.services

  name              = "/ecs/${var.project_name}/${var.environment}/${each.key}"
  retention_in_days = 14
}