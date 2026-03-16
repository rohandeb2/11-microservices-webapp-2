  # --- modules/security/secrets.tf ---

  # 1️⃣ Main Application Secrets
  resource "aws_secretsmanager_secret" "app_secrets" {
    name                    = "${var.project_name}-app-secrets-${var.environment}"
    description             = "Main secret store for 11-microservices app"
    kms_key_id              = aws_kms_key.main.arn
    recovery_window_in_days = 7

    tags = {
      Name = "${var.project_name}-secrets"
      Env  = var.environment
    }
  }

  resource "aws_secretsmanager_secret_version" "initial" {
    secret_id = aws_secretsmanager_secret.app_secrets.id

    secret_string = jsonencode({
      REDIS_PASSWORD       = "redis-password"
      PAYMENT_GATEWAY_KEY  = "placeholder"
    })

    lifecycle {
      ignore_changes = [secret_string]
    }
  }

  # 2️⃣ AI Log Analyzer Secrets
  resource "aws_secretsmanager_secret" "ai_secrets" {
    name = "ai/${var.project_name}/${var.environment}/log-analyzer"
  }

  resource "aws_secretsmanager_secret_version" "ai_initial" {
    secret_id = aws_secretsmanager_secret.ai_secrets.id

    secret_string = jsonencode({
      AI_LOG_ANALYZER_KEY = "your-openai-key-here"
      SLACK_WEBHOOK_URL   = "https://hooks.slack.com/services/Txxx/Bxxx/Xxxx"
    })

    lifecycle {
      ignore_changes = [secret_string]
    }
  }