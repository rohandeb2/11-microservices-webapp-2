# --- Root Outputs for Dev Environment ---

# 1️⃣ Networking Layer Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnets" {
  description = "IDs of public subnets"
  value       = module.networking.public_subnets
}

output "private_app_subnets" {
  description = "IDs of private application subnets"
  value       = module.networking.private_app_subnets
}

output "private_db_subnets" {
  description = "IDs of private DB subnets"
  value       = module.networking.private_db_subnets
}

output "route53_zone_id" {
  description = "Route53 Hosted Zone ID"
  value       = module.networking.route53_zone_id
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name for the website"
  value       = module.networking.cloudfront_domain_name
}

output "cloudfront_arn" {
  description = "CloudFront Distribution ARN"
  value       = module.networking.cloudfront_arn
}

# 2️⃣ Compute Layer Outputs
output "cluster_name" {
  description = "EKS Cluster name"
  value       = module.compute.cluster_name
}

output "cluster_endpoint" {
  description = "EKS Cluster API endpoint"
  value       = module.compute.cluster_endpoint
}

output "eks_nodes_sg_id" {
  description = "Security Group ID of EKS worker nodes"
  value       = module.compute.eks_nodes_sg_id
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.compute.alb_dns_name
}

output "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch metrics"
  value       = module.compute.alb_arn_suffix
}

output "ecr_repository_urls" {
  description = "ECR repository URLs for all microservices"
  value       = module.compute.ecr_repository_urls
}

output "eks_oidc_issuer_url" {
  description = "OIDC issuer URL of the EKS cluster for IRSA"
  value       = module.compute.eks_oidc_issuer_url
}

# 3️⃣ Security Layer Outputs
output "certificate_arn" {
  description = "ACM Certificate ARN for CloudFront / ALB HTTPS"
  value       = module.security.certificate_arn
}

output "kms_key_arn" {
  description = "KMS Key ARN for encrypting secrets and X-Ray"
  value       = module.security.kms_key_arn
}

output "eks_cluster_role_arn" {
  description = "IAM Role ARN of the EKS cluster"
  value       = module.security.eks_cluster_role_arn
}

output "eks_node_role_arn" {
  description = "IAM Role ARN for EKS worker nodes"
  value       = module.security.eks_node_role_arn
}

output "eks_node_role_name" {
  description = "IAM Role Name for EKS worker nodes"
  value       = module.security.eks_node_role_name
}

output "waf_arn" {
  description = "WAF ARN for CloudFront"
  value       = module.security.waf_arn
}

# 4️⃣ Data Layer Outputs
output "redis_primary_endpoint" {
  description = "Primary endpoint for Redis cluster"
  value       = module.data.redis_primary_endpoint
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.data.dynamodb_table_name
}

# 5️⃣ Messaging Layer Outputs
output "sns_order_topic_arn" {
  description = "ARN of the SNS topic for order events"
  value       = module.messaging.order_topic_arn
}

output "sqs_email_queue_url" {
  description = "URL of the SQS queue for email processing"
  value       = module.messaging.email_queue_url
}

output "sqs_email_queue_arn" {
  description = "ARN of the SQS queue for email processing"
  value       = module.messaging.email_queue_arn
}

# 6️⃣ Observability Layer Outputs
output "log_group_name" {
  description = "CloudWatch Log Group for EKS microservices"
  value       = module.observability.log_group_name
}

output "dashboard_arn" {
  description = "CloudWatch Dashboard ARN"
  value       = module.observability.dashboard_arn
}

output "xray_sampling_rule_arn" {
  description = "ARN of the X-Ray sampling rule"
  value       = module.observability.xray_sampling_rule_arn
}

# 7️⃣ Global IAM Outputs
output "admin_group_arn" {
  description = "IAM Group ARN for Admins"
  value       = module.global_iam.admin_group_arn
}

output "rohan_user_arn" {
  description = "IAM User ARN for Rohan DevOps"
  value       = module.global_iam.rohan_user_arn
}

output "cicd_deployer_user_arn" {
  description = "IAM User ARN for GitHub Actions Deployer"
  value       = module.global_iam.cicd_deployer_user_arn
}

output "cicd_deployer_access_key_id" {
  description = "Access Key ID for GitHub Actions Deployer"
  value       = module.global_iam.cicd_deployer_access_key_id
}


# # --- environments/dev/outputs.tf ---

# # 1. Networking Outputs
# output "website_url" {
#   description = "The public URL of your Netflix-clone application"
#   value       = "https://${module.networking.cloudfront_domain_name}"
# }

# # 2. Compute Outputs (Crucial for Kubectl)
# output "eks_cluster_name" {
#   description = "The name of the EKS cluster for context switching"
#   value       = module.compute.cluster_name
# }

# output "eks_cluster_endpoint" {
#   description = "The API endpoint for your EKS cluster"
#   value       = module.compute.cluster_endpoint
# }

# # 3. Registry Outputs (Crucial for CI/CD)
# output "ecr_repository_urls" {
#   description = "The URLs of the ECR repositories for your 11 microservices"
#   value       = module.compute.ecr_repository_urls
# }

# # 4. Security Outputs
# output "kms_key_arn" {
#   description = "The Master Encryption Key ARN"
#   value       = module.security.kms_key_arn
# }

# # 5. Data Outputs
# output "redis_primary_endpoint" {
#   description = "The Redis endpoint for the cartservice"
#   value       = module.data.redis_primary_endpoint
# }

# output "sns_order_topic_arn" {
#   description = "ARN of the SNS topic for order events"
#   value       = module.messaging.order_topic_arn
# }

# output "sqs_email_queue_url" {
#   description = "URL of the SQS Email Queue"
#   value       = module.messaging.email_queue_url
# }

# output "cloudwatch_dashboard_arn" {
#   description = "ARN of CloudWatch dashboard"
#   value       = module.observability.dashboard_arn
# }

# output "xray_sampling_rule_arn" {
#   description = "ARN of X-Ray sampling rule"
#   value       = module.observability.xray_sampling_rule_arn
# }

# output "waf_arn" {
#   description = "ARN of the WAF Web ACL"
#   value       = module.security.waf_arn
# }

# output "cicd_deployer_user" {
#   description = "IAM user for CI/CD deployment"
#   value       = module.global_iam.cicd_deployer_name
# }

# output "dynamodb_table_name" {
#   description = "Primary DynamoDB table name"
#   value       = module.data.dynamodb_table_name
# }

# output "rds_cluster_endpoint" {
#   description = "Primary RDS cluster endpoint"
#   value       = module.data.rds_cluster_endpoint
# }