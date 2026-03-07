# --- environments/prod/outputs.tf ---

# 1. Production Entry Point
output "production_website_url" {
  description = "The primary production URL (CloudFront Endpoint)"
  value       = "https://${module.networking.cloudfront_domain_name}"
}

# 2. Kubernetes API Access (For SRE Team)
output "prod_eks_cluster_name" {
  description = "The name of the Production EKS cluster"
  value       = module.compute.cluster_name
}

output "prod_eks_cluster_endpoint" {
  description = "The API endpoint for the Production cluster"
  value       = module.compute.cluster_endpoint
}

# 3. Secure Data Endpoints
output "prod_redis_primary_endpoint" {
  description = "Primary Redis endpoint for production cartservice"
  value       = module.data.redis_primary_endpoint
}

output "prod_db_table_name" {
  description = "The Production DynamoDB table name"
  value       = module.data.dynamodb_table_name
}

# 4. Observability Dashboard
output "prod_cloudwatch_dashboard_url" {
  description = "URL to the Production CloudWatch Dashboard for SRE monitoring"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?#dashboards:name=${module.observability.dashboard_name}"
}

# 5. Container Registry (For CI/CD Pipeline)
output "prod_ecr_repository_urls" {
  description = "Production ECR URLs for image tagging and pushing"
  value       = module.compute.ecr_repository_urls
}