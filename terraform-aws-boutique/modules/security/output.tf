# ACM Certificate
output "certificate_arn" {
  value = aws_acm_certificate.cert.arn
}



# IAM Roles for EKS
output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_nodes.arn
}

output "eks_node_role_name" {
  value = aws_iam_role.eks_nodes.name
}
output "kms_key_arn" {
  value = aws_kms_key.main.arn # Ensure resource name is "main"
}
output "waf_arn" {
  value = aws_wafv2_web_acl.main.arn
}


output "secrets_manager_arn" {
  description = "Secrets Manager ARN for application secrets"
  value       = aws_secretsmanager_secret.app_secrets.arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "IAM role used by AWS Load Balancer Controller"
  value       = aws_iam_role.lbc_role.arn
}

output "kms_key_alias" {
  value = aws_kms_alias.main.name
}