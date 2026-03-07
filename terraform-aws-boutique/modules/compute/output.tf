# EKS Cluster related outputs
output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "eks_oidc_issuer_url" {
  value = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "eks_nodes_sg_id" {
  # FIX: Match the resource name in main.tf
  value = aws_security_group.eks_cluster_sg.id
}

# ECR repository URLs
output "ecr_repository_urls" {
  description = "List of ECR repository URLs for the microservices"
  # Ensures this matches your ecr.tf resource name
  value = { for k, v in aws_ecr_repository.microservices : k => v.repository_url }
}

# NOTE: Only include these if the aws_lb resource is actually in this module's main.tf
# If you get "Resource not declared" errors, move these to the networking module


output "alb_arn_suffix" {
  value = try(aws_lb.main.arn_suffix, "")
}
output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "The zone_id of the load balancer"
  value       = aws_lb.main.zone_id
}