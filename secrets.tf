resource "aws_secretsmanager_secret" "db_username" {
  name = "${var.project_name}/${var.environment}/db/username"
}

resource "aws_secretsmanager_secret_version" "db_username_value" {
  secret_id     = aws_secretsmanager_secret.db_username.id
  secret_string = var.db_username
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.project_name}/${var.environment}/db/password"
}

resource "aws_secretsmanager_secret_version" "db_password_value" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}

resource "aws_secretsmanager_secret" "jwt_secret" {
  name = "${var.project_name}/${var.environment}/jwt/secret"
}

resource "aws_secretsmanager_secret_version" "jwt_secret_value" {
  secret_id     = aws_secretsmanager_secret.jwt_secret.id
  secret_string = var.jwt_secret
}

resource "aws_secretsmanager_secret" "config_repo_username" {
  count = var.config_repo_private ? 1 : 0
  name  = "${var.project_name}/${var.environment}/config-repo/username"
}

resource "aws_secretsmanager_secret_version" "config_repo_username_value" {
  count         = var.config_repo_private ? 1 : 0
  secret_id     = aws_secretsmanager_secret.config_repo_username[0].id
  secret_string = var.config_repo_username
}

resource "aws_secretsmanager_secret" "config_repo_token" {
  count = var.config_repo_private ? 1 : 0
  name  = "${var.project_name}/${var.environment}/config-repo/token"
}

resource "aws_secretsmanager_secret_version" "config_repo_token_value" {
  count         = var.config_repo_private ? 1 : 0
  secret_id     = aws_secretsmanager_secret.config_repo_token[0].id
  secret_string = var.config_repo_token
}