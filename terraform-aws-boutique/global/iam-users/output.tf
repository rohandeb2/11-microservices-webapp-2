# --- global/iam-users/outputs.tf ---

output "admin_user_arns" {
  value = aws_iam_user.rohan[*].arn
}

output "cicd_deployer_user_name" {
  description = "The name of the CI/CD IAM user"
  value       = aws_iam_user.cicd_deployer.name
}

output "cicd_deployer_user_arn" {
  description = "The ARN of the CI/CD IAM user"
  value       = aws_iam_user.cicd_deployer.arn
}

# Note: We do not output Secret Keys here for security. 
# You should generate them manually in the console or via a 'pgp' encrypted resource.