output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  value = aws_subnet.private_app[*].id
}

output "private_db_subnet_ids" {
  value = aws_subnet.private_db[*].id
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "alb_arn" {
  value = aws_lb.main.arn
}

output "gateway_target_group_arn" {
  value = aws_lb_target_group.gateway.arn
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  value = aws_ecs_cluster.main.arn
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.address
}

output "rds_port" {
  value = aws_db_instance.mysql.port
}

output "cloudmap_namespace_name" {
  value = aws_service_discovery_private_dns_namespace.main.name
}

output "cloudmap_namespace_id" {
  value = aws_service_discovery_private_dns_namespace.main.id
}

output "ecr_repository_urls" {
  value = {
    for service_name, repo in aws_ecr_repository.services :
    service_name => repo.repository_url
  }
}

output "ecs_service_names" {
  value = {
    for service_name, svc in aws_ecs_service.services :
    service_name => svc.name
  }
}

output "ecs_task_definition_families" {
  value = {
    for service_name, taskdef in aws_ecs_task_definition.services :
    service_name => taskdef.family
  }
}