variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnets"
}

variable "private_app_subnet_cidrs" {
  type        = list(string)
  description = "Private app subnets"
}

variable "private_db_subnet_cidrs" {
  type        = list(string)
  description = "Private DB subnets"
}

variable "db_name" {
  type        = string
  description = "RDS database name"
}

variable "db_username" {
  type        = string
  description = "RDS username"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "RDS password"
}

variable "jwt_secret" {
  type        = string
  sensitive   = true
  description = "JWT secret for msvc-users"
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "RDS instance class"
}

variable "db_allocated_storage" {
  type        = number
  default     = 20
  description = "RDS allocated storage"
}

variable "config_repo_uri" {
  type        = string
  description = "Git repo URI for config-data"
}

variable "config_repo_branch" {
  type        = string
  default     = "deploy"
  description = "Git branch for config-data"
}

variable "config_repo_search_paths" {
  type        = string
  default     = "config-data"
  description = "Search paths inside config repository"
}

variable "config_repo_private" {
  type        = bool
  default     = false
  description = "Whether config repo is private"
}

variable "config_repo_username" {
  type        = string
  default     = ""
  description = "Git username"
}

variable "config_repo_token" {
  type        = string
  sensitive   = true
  default     = ""
  description = "Git token or PAT"
}

variable "alb_listener_port" {
  type        = number
  default     = 80
  description = "ALB listener port"
}

variable "health_check_path_gateway" {
  type        = string
  default     = "/actuator/health"
  description = "Gateway health check path"
}

variable "services" {
  type = map(object({
    port          = number
    cpu           = number
    memory        = number
    desired_count = number
    public        = bool
  }))
  description = "Services configuration"
}