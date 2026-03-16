# --- global/iam-users/main.tf ---

# 1️⃣ Admin Group
resource "aws_iam_group" "admins" {
  name = "infra-admins"

  tags = {
    Project = var.project_name
    Env     = var.environment
  }
}

resource "aws_iam_group_policy_attachment" "admin_access" {
  group      = aws_iam_group.admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# 2️⃣ Admin User (Rohan)
resource "aws_iam_user" "rohan" {
  name = "rohan-devops"

  tags = {
    Project = var.project_name
    Env     = var.environment
  }
}

resource "aws_iam_user_group_membership" "rohan_admin" {
  user   = aws_iam_user.rohan.name
  groups = [aws_iam_group.admins.name]
}

# Optional: Enable console login and require password reset
resource "aws_iam_user_login_profile" "rohan_console" {
  user = aws_iam_user.rohan.name
  password_reset_required = true
}

# Optional: MFA device for admin
resource "aws_iam_virtual_mfa_device" "rohan_mfa" {
  name           = "rohan-devops-mfa"
  virtual_mfa_device_name = "rohan-devops-mfa"
  users          = [aws_iam_user.rohan.name]
}

# 3️⃣ CI/CD Pipeline User (GitHub Actions Deployer)
resource "aws_iam_user" "cicd_deployer" {
  name = "github-actions-deployer"

  tags = {
    Project = var.project_name
    Env     = var.environment
  }
}

# 3a. Least Privilege Policy for Terraform Deployer
resource "aws_iam_policy" "deployer_policy" {
  name        = "TerraformDeployerPolicy"
  description = "Least privilege policy for GitHub Actions Terraform deployer"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # S3: Only project buckets
      {
        Effect = "Allow"
        Action = ["s3:*"]
        Resource = [
          "arn:aws:s3:::${var.project_name}-assets-${var.environment}",
          "arn:aws:s3:::${var.project_name}-assets-${var.environment}/*",
          "arn:aws:s3:::${var.project_name}-athena-results-${var.environment}",
          "arn:aws:s3:::${var.project_name}-athena-results-${var.environment}/*"
        ]
      },
      # DynamoDB: Only project table
      {
        Effect = "Allow"
        Action = ["dynamodb:*"]
        Resource = "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.project_name}-data-${var.environment}"
      },
      # EKS: Cluster & Node Role
      {
        Effect = "Allow"
        Action = ["eks:*", "iam:PassRole"]
        Resource = [
          "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.project_name}-cluster",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-eks-cluster-role",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-eks-node-role"
        ]
      },
      # KMS: Only project key
      {
        Effect = "Allow"
        Action = ["kms:*"]
        Resource = "arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/${var.kms_key_id}"
      },
      # Secrets Manager: Only project secrets
      {
        Effect = "Allow"
        Action = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}-*"
      }
    ]
  })
}

# 3b. Attach Policy to Deployer User
resource "aws_iam_user_policy_attachment" "deployer_attach" {
  user       = aws_iam_user.cicd_deployer.name
  policy_arn = aws_iam_policy.deployer_policy.arn
}

# 3c. Access Keys for GitHub Actions
resource "aws_iam_access_key" "cicd_key" {
  user = aws_iam_user.cicd_deployer.name
}


# # --- global/iam-users/main.tf ---

# # 1. Admin Group
# resource "aws_iam_group" "admins" {
#   name = "infra-admins"
# }

# resource "aws_iam_group_policy_attachment" "admin_access" {
#   group      = aws_iam_group.admins.name
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
# }

# # 2. Individual IAM User (You)
# resource "aws_iam_user" "rohan" {
#   name = "rohan-devops"
# }

# resource "aws_iam_user_group_membership" "rohan_admin" {
#   user   = aws_iam_user.rohan.name
#   groups = [aws_iam_group.admins.name]
# }

# # 3. CI/CD Pipeline User (The "Deployer")
# # This user will be used by GitHub Actions to run 'terraform apply'
# resource "aws_iam_user" "cicd_deployer" {
#   name = "github-actions-deployer"
# }

# # Industry Standard: A Custom Policy for the Deployer (Least Privilege)
# resource "aws_iam_user_policy" "deployer_policy" {
#   name = "TerraformDeployerPolicy"
#   user = aws_iam_user.cicd_deployer.name

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = [
#           "ec2:*", "s3:*", "eks:*", "iam:*", "rds:*", "dynamodb:*", "kms:*"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }