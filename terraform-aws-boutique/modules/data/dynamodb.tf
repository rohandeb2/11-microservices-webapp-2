# --- modules/data/dynamodb.tf ---

# 1. DynamoDB Table for Application State (e.g., Email Logs or Ad Inventory)
resource "aws_dynamodb_table" "app_table" {
  name           = "${var.project_name}-data-${var.environment}"
  billing_mode   = "PAY_PER_REQUEST" # Cost-effective for dev/fresher projects
  hash_key       = "id"              # Partition Key
  range_key      = "timestamp"       # Sort Key

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  # 2. TTL (Time To Live) - Industry Standard for cleaning up old logs/data
  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  # 3. Encryption at Rest
  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn # Using our Security Module Key
  }

  # 4. Point-In-Time Recovery (Backup)
  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name = "${var.project_name}-dynamodb"
    Env  = var.environment
  }
}