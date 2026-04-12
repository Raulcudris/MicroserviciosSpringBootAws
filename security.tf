resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "ALB public security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_gateway" {
  name        = "${var.project_name}-${var.environment}-ecs-gateway-sg"
  description = "Gateway ECS SG"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Outbound all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_internal" {
  name        = "${var.project_name}-${var.environment}-ecs-internal-sg"
  description = "Internal ECS SG"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Outbound all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "RDS MySQL SG"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Outbound all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ALB -> Gateway
resource "aws_security_group_rule" "alb_to_gateway" {
  type                     = "ingress"
  from_port                = var.services["msvc-gateway"].port
  to_port                  = var.services["msvc-gateway"].port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_gateway.id
  source_security_group_id = aws_security_group.alb.id
  description              = "Allow ALB to gateway"
}

# Gateway -> Internal services
resource "aws_security_group_rule" "gateway_to_internal" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_internal.id
  source_security_group_id = aws_security_group.ecs_gateway.id
  description              = "Allow gateway to internal services"
}

# Internal -> Internal
resource "aws_security_group_rule" "internal_to_internal" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_internal.id
  source_security_group_id = aws_security_group.ecs_internal.id
  description              = "Allow internal ECS communication"
}

# Internal -> Gateway
resource "aws_security_group_rule" "internal_to_gateway" {
  type                     = "ingress"
  from_port                = var.services["msvc-gateway"].port
  to_port                  = var.services["msvc-gateway"].port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_gateway.id
  source_security_group_id = aws_security_group.ecs_internal.id
  description              = "Allow internal services to call gateway if needed"
}

# Gateway -> RDS
resource "aws_security_group_rule" "gateway_to_rds" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.ecs_gateway.id
  description              = "Allow gateway ECS to access RDS"
}

# Internal -> RDS
resource "aws_security_group_rule" "internal_to_rds" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.ecs_internal.id
  description              = "Allow internal ECS to access RDS"
}