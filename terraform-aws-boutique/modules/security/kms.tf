# --- modules/security/kms.tf ---

# 1. Define the Customer Managed Key (CMK)
resource "aws_kms_key" "main" {
  description             = "Master encryption key for ${var.project_name} resources"
  deletion_window_in_days = 7
  enable_key_rotation     = true # Critical for CIS compliance and industry standards

  # Policy that allows the root account full access and allows IAM roles to use the key
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable Root User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow EKS and App Roles to use the key"
        Effect = "Allow"
        Principal = {
          AWS = "*" # In production, restrict this to specific IAM Role ARNs
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:CallerAccount" = "${data.aws_caller_identity.current.account_id}"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-kms"
    Env  = var.environment
  }
}

# 2. Create a user-friendly Alias for the key
resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-key"
  target_key_id = aws_kms_key.main.key_id
}

# Data source to get the current AWS Account ID for the policy
data "aws_caller_identity" "current" {}