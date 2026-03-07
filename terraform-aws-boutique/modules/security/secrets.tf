# --- modules/security/secrets.tf ---

# 1. Create the Secret container
resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "${var.project_name}-app-secrets-${var.environment}"
  description             = "Main secret store for 11-microservices app"
  kms_key_id              = aws_kms_key.main.arn # Encrypting with our Customer Managed Key
  recovery_window_in_days = 7                # Allows for accidental deletion recovery

  tags = {
    Name = "${var.project_name}-secrets"
    Env  = var.environment
  }
}

# 2. Secret Version (Optional: Placeholder for initial structure)
# In a real pipeline, you'd populate this via a script or the AWS CLI
resource "aws_secretsmanager_secret_version" "initial" {
  secret_id     = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    REDIS_PASSWORD = "redis-password"
    PAYMENT_GATEWAY_KEY = "placeholder"
  })
  
  # Prevent Terraform from overwriting manual changes made in the AWS Console
  lifecycle {
    ignore_changes = [secret_string]
  }
}