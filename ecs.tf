locals {
  namespace_name = aws_service_discovery_private_dns_namespace.main.name

  service_dns = {
    for service_name, service_data in var.services :
    service_name => "${service_name}.${local.namespace_name}"
  }

  env_by_service = {
    "msvc-config" = [
      {
        name  = "SPRING_PROFILES_ACTIVE"
        value = var.environment
      },
      {
        name  = "SERVER_PORT"
        value = tostring(var.services["msvc-config"].port)
      },
      {
        name  = "SPRING_CLOUD_CONFIG_SERVER_GIT_URI"
        value = var.config_repo_uri
      },
      {
        name  = "SPRING_CLOUD_CONFIG_SERVER_GIT_DEFAULT_LABEL"
        value = var.config_repo_branch
      },
      {
        name  = "SPRING_CLOUD_CONFIG_SERVER_GIT_SEARCH_PATHS"
        value = var.config_repo_search_paths
      }
    ]

    "msvc-eureka" = [
      {
        name  = "SPRING_PROFILES_ACTIVE"
        value = var.environment
      },
      {
        name  = "SERVER_PORT"
        value = tostring(var.services["msvc-eureka"].port)
      },
      {
        name  = "SPRING_CONFIG_IMPORT"
        value = "optional:configserver:http://${local.service_dns["msvc-config"]}:${var.services["msvc-config"].port}"
      }
    ]

    "msvc-gateway" = [
      {
        name  = "SPRING_PROFILES_ACTIVE"
        value = var.environment
      },
      {
        name  = "SERVER_PORT"
        value = tostring(var.services["msvc-gateway"].port)
      },
      {
        name  = "SPRING_CONFIG_IMPORT"
        value = "optional:configserver:http://${local.service_dns["msvc-config"]}:${var.services["msvc-config"].port}"
      },
      {
        name  = "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"
        value = "http://msvc-eureka.inventario-ms.local:8761/eureka/"
      }
    ]
    "msvc-orders" = [
      {
        name  = "SPRING_PROFILES_ACTIVE"
        value = var.environment
      },
      {
        name  = "SERVER_PORT"
        value = tostring(var.services["msvc-orders"].port)
      },
      {
        name  = "SPRING_CONFIG_IMPORT"
        value = "optional:configserver:http://${local.service_dns["msvc-config"]}:${var.services["msvc-config"].port}"
      },
      {
        name  = "DB_HOST"
        value = aws_db_instance.mysql.address
      }
    ]

    "msvc-pay" = [
      {
        name  = "SPRING_PROFILES_ACTIVE"
        value = var.environment
      },
      {
        name  = "SERVER_PORT"
        value = tostring(var.services["msvc-pay"].port)
      },
      {
        name  = "SPRING_CONFIG_IMPORT"
        value = "optional:configserver:http://${local.service_dns["msvc-config"]}:${var.services["msvc-config"].port}"
      },
      {
        name  = "DB_HOST"
        value = aws_db_instance.mysql.address
      }
    ]

    "msvc-products" = [
      {
        name  = "SPRING_PROFILES_ACTIVE"
        value = var.environment
      },
      {
        name  = "SERVER_PORT"
        value = tostring(var.services["msvc-products"].port)
      },
      {
        name  = "SPRING_CONFIG_IMPORT"
        value = "optional:configserver:http://${local.service_dns["msvc-config"]}:${var.services["msvc-config"].port}"
      },
      {
        name  = "DB_HOST"
        value = aws_db_instance.mysql.address
      }
    ]

    "msvc-users" = [
      {
        name  = "SPRING_PROFILES_ACTIVE"
        value = var.environment
      },
      {
        name  = "SERVER_PORT"
        value = tostring(var.services["msvc-users"].port)
      },
      {
        name  = "SPRING_CONFIG_IMPORT"
        value = "optional:configserver:http://${local.service_dns["msvc-config"]}:${var.services["msvc-config"].port}"
      },
      {
        name  = "DB_HOST"
        value = aws_db_instance.mysql.address
      },
      {
        name  = "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"
        value = "http://msvc-eureka.inventario-ms.local:8761/eureka/"
      },
      {
        name  = "EUREKA_INSTANCE_PREFER_IP_ADDRESS"
        value = "false"
      },
      {
        name  = "EUREKA_INSTANCE_HOSTNAME"
        value = "msvc-users.inventario-ms.local"
      },
      {
        name  = "EUREKA_INSTANCE_NON_SECURE_PORT"
        value = "8004"
      }
    ]
  }

  default_db_secrets = [
    {
      name      = "DB_USERNAME"
      valueFrom = aws_secretsmanager_secret.db_username.arn
    },
    {
      name      = "DB_PASSWORD"
      valueFrom = aws_secretsmanager_secret.db_password.arn
    }
  ]

  config_git_secrets = var.config_repo_private ? [
    {
      name      = "SPRING_CLOUD_CONFIG_SERVER_GIT_USERNAME"
      valueFrom = aws_secretsmanager_secret.config_repo_username[0].arn
    },
    {
      name      = "SPRING_CLOUD_CONFIG_SERVER_GIT_PASSWORD"
      valueFrom = aws_secretsmanager_secret.config_repo_token[0].arn
    }
  ] : []

  secrets_by_service = {
    "msvc-config"   = concat(local.config_git_secrets, [])
    "msvc-eureka"   = []
    "msvc-gateway"  = []
    "msvc-orders"   = local.default_db_secrets
    "msvc-pay"      = local.default_db_secrets
    "msvc-products" = local.default_db_secrets
    "msvc-users" = concat(
      local.default_db_secrets,
      [
        {
          name      = "JWT_SECRET"
          valueFrom = aws_secretsmanager_secret.jwt_secret.arn
        }
      ]
    )
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"
}

resource "aws_ecs_task_definition" "services" {
  for_each = var.services

  family                   = "${var.project_name}-${var.environment}-${each.key}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(each.value.cpu)
  memory                   = tostring(each.value.memory)
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = each.key
      image     = "${aws_ecr_repository.services[each.key].repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = each.value.port
          hostPort      = each.value.port
          protocol      = "tcp"
        }
      ]

      environment = local.env_by_service[each.key]
      secrets     = local.secrets_by_service[each.key]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.services[each.key].name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = each.key
        }
      }
    }
  ])
}

resource "aws_ecs_service" "services" {
  for_each = var.services

  name            = "${var.project_name}-${var.environment}-${each.key}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.services[each.key].arn
  desired_count   = each.value.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private_app[*].id
    security_groups  = each.key == "msvc-gateway" ? [aws_security_group.ecs_gateway.id] : [aws_security_group.ecs_internal.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.services[each.key].arn
  }

  dynamic "load_balancer" {
    for_each = each.key == "msvc-gateway" ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.gateway.arn
      container_name   = each.key
      container_port   = each.value.port
    }
  }

  depends_on = [
    aws_lb_listener.http,
    aws_ecs_task_definition.services
  ]
}