# # --- global/iam-users/outputs.tf ---

# output "admin_user_arns" {
#   value = aws_iam_user.rohan[*].arn
# }

# output "cicd_deployer_user_name" {
#   description = "The name of the CI/CD IAM user"
#   value       = aws_iam_user.cicd_deployer.name
# }

# output "cicd_deployer_user_arn" {
#   description = "The ARN of the CI/CD IAM user"
#   value       = aws_iam_user.cicd_deployer.arn
# }

# # Note: We do not output Secret Keys here for security. 
# # You should generate them manually in the console or via a 'pgp' encrypted resource.

# Admin Group & User
output "admin_group_name" {
  description = "The IAM group name for infra admins"
  value       = aws_iam_group.admins.name
}

output "admin_user_name" {
  description = "The IAM username of the main admin"
  value       = aws_iam_user.rohan.name
}

# CI/CD Deployer User & Keys
output "cicd_user_name" {
  description = "The IAM username for CI/CD deployer"
  value       = aws_iam_user.cicd_deployer.name
}

output "cicd_access_key_id" {
  description = "Access key ID for the CI/CD deployer user"
  value       = aws_iam_access_key.cicd_key.id
}

output "cicd_secret_access_key" {
  description = "Secret access key for the CI/CD deployer user"
  value       = aws_iam_access_key.cicd_key.secret
  sensitive   = true
}

# Terraform Deployer Policy
output "deployer_policy_arn" {
  description = "ARN of the least privilege policy attached to the CI/CD deployer"
  value       = aws_iam_policy.deployer_policy.arn
}