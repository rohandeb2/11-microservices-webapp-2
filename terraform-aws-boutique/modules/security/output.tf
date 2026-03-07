# ACM Certificate
output "certificate_arn" {
  value = aws_acm_certificate.cert.arn
}

# Secrets Manager
output "secrets_manager_arn" {
  value = aws_secretsmanager_secret.main.arn
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
