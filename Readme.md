# Inventario Microservices - Terraform + ECS Fargate + RDS MySQL + Cloud Map

Este paquete crea una base lista para desplegar:

- Microservicios Java 11 en ECS Fargate
- MySQL en RDS
- Application Load Balancer público
- ECR para imágenes Docker
- Secrets Manager para secretos
- CloudWatch Logs
- Service Discovery interno con AWS Cloud Map

## Microservicios

- configservices: 8081
- eurekaservices: 8761
- gatewayservices: 8080
- orderservices: 8002
- paymentservice: 8003
- productservice: 8001
- userservice: 8004

## Arquitectura

- **ALB público**
  - todo el tráfico entra por `gatewayservices`
- **ECS Fargate**
  - `gatewayservices` corre en subredes privadas detrás del ALB
  - `configservices`, `eurekaservices`, `orderservices`, `paymentservice`, `productservice` y `userservice` corren en subredes privadas
  - todos se registran en AWS Cloud Map para resolución interna por DNS
- **NAT Gateway**
  - permite salida a internet para tasks privadas, especialmente `configservices`, que necesita leer `config-data` desde GitHub
- **RDS MySQL**
  - corre en subredes privadas
  - solo acepta conexiones desde los security groups de ECS

## Importante

### Config Server

`configservices` obtiene configuración desde un repositorio GitHub (`config-data`) usando Spring Cloud Config Server.

Si el repositorio es privado:

- activa `config_repo_private = true`
- configura:
  - `config_repo_username`
  - `config_repo_token`

## Archivos principales

- `provider.tf`
- `variables.tf`
- `terraform.tfvars`
- `networking.tf`
- `security.tf`
- `ecr.tf`
- `alb.tf`
- `iam.tf`
- `cloudwatch.tf`
- `cloudmap.tf`
- `ecs.tf`
- `rds.tf`
- `secrets.tf`
- `outputs.tf`

## Paso 1. Configura credenciales AWS

```bash
aws sts get-caller-identity
aws configure list