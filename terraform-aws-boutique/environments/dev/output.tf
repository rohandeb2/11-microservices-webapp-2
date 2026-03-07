# --- environments/dev/outputs.tf ---

# 1. Networking Outputs
output "website_url" {
  description = "The public URL of your Netflix-clone application"
  value       = "https://${module.networking.cloudfront_domain_name}"
}

# 2. Compute Outputs (Crucial for Kubectl)
output "eks_cluster_name" {
  description = "The name of the EKS cluster for context switching"
  value       = module.compute.cluster_name
}

output "eks_cluster_endpoint" {
  description = "The API endpoint for your EKS cluster"
  value       = module.compute.cluster_endpoint
}

# 3. Registry Outputs (Crucial for CI/CD)
output "ecr_repository_urls" {
  description = "The URLs of the ECR repositories for your 11 microservices"
  value       = module.compute.ecr_repository_urls
}

# 4. Security Outputs
output "kms_key_arn" {
  description = "The Master Encryption Key ARN"
  value       = module.security.kms_key_arn
}

# 5. Data Outputs
output "redis_primary_endpoint" {
  description = "The Redis endpoint for the cartservice"
  value       = module.data.redis_primary_endpoint
}