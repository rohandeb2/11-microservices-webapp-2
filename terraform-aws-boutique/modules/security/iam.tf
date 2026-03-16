# Use locals to create a clean, reusable OIDC string
locals {
  oidc_clean = trimprefix(trimsuffix(var.eks_oidc_issuer_url, "/"), "https://")
}

data "aws_iam_policy_document" "eks_oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      # FIXED: Cleaned OIDC string + :sub
      variable = "${local.oidc_clean}:sub"
      values   = ["system:serviceaccount:boutique-app:boutique-admin-sa"]
    }

    condition {
      test     = "StringEquals"
      # FIXED: Cleaned OIDC string + :aud
      variable = "${local.oidc_clean}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      # FIXED: Full ARN using the dynamic account ID and cleaned string
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_clean}"]
      type        = "Federated"
    }
  }
}

# 2. Dedicated IAM Role for Microservices
resource "aws_iam_role" "microservice_role" {
  name               = "${var.project_name}-microservice-role"
  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role_policy.json
}

# 3. Policy to allow access to KMS and Secrets Manager
# --- modules/security/iam.tf ---

resource "aws_iam_policy" "app_permissions" {
  name        = "${var.project_name}-app-permissions"
  description = "Permissions for microservices to access secrets and encryption"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Effect   = "Allow"
        Resource = aws_kms_key.main.arn
      },
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        # CHANGE: Allow access to all secrets starting with 'boutique/'
        # This matches your 'boutique/production/redis' request
        # Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:boutique*"
        Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}*"
        Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:ai/*
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app_attach" {
  role       = aws_iam_role.microservice_role.name
  policy_arn = aws_iam_policy.app_permissions.arn
}

