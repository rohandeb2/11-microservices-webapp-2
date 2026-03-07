# --- global/iam-users/main.tf ---

# 1. Admin Group
resource "aws_iam_group" "admins" {
  name = "infra-admins"
}

resource "aws_iam_group_policy_attachment" "admin_access" {
  group      = aws_iam_group.admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# 2. Individual IAM User (You)
resource "aws_iam_user" "rohan" {
  name = "rohan-devops"
}

resource "aws_iam_user_group_membership" "rohan_admin" {
  user   = aws_iam_user.rohan.name
  groups = [aws_iam_group.admins.name]
}

# 3. CI/CD Pipeline User (The "Deployer")
# This user will be used by GitHub Actions to run 'terraform apply'
resource "aws_iam_user" "cicd_deployer" {
  name = "github-actions-deployer"
}

# Industry Standard: A Custom Policy for the Deployer (Least Privilege)
resource "aws_iam_user_policy" "deployer_policy" {
  name = "TerraformDeployerPolicy"
  user = aws_iam_user.cicd_deployer.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ec2:*", "s3:*", "eks:*", "iam:*", "rds:*", "dynamodb:*", "kms:*"
        ]
        Resource = "*"
      }
    ]
  })
}