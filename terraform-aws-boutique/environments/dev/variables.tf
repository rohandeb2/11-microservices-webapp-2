# --- Project General Settings ---
variable "project_name" {
  description = "The name of the project used for naming and tagging"
  type        = string
  default     = "boutique-app"
}

variable "environment" {
  description = "The deployment environment (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "The AWS region where resources will be deployed"
  type        = string
  default     = "ap-south-1"
}

# --- Networking ---
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "domain_name" {
  description = "The primary domain name for the application"
  type        = string
}

# --- Compute / EKS ---
variable "eks_instance_type" {
  description = "The EC2 instance type for EKS worker nodes"
  type        = string
  default     = "m7i-flex.large"
}

variable "eks_node_count" {
  description = "Number of worker nodes in the EKS cluster"
  type        = number
  default     = 2
}

# --- Security ---
variable "enable_security_hub" {
  description = "Toggle to enable or disable AWS Security Hub"
  type        = bool
  default     = true
}

# --- Data Layer (Redis / ElastiCache) ---
variable "redis_node_type" {
  description = "The instance class for ElastiCache Redis nodes"
  type        = string
  default     = "cache.t3.medium"
}

variable "redis_node_count" {
  description = "Number of nodes in the Redis replication group"
  type        = number
  default     = 2
}

# --- Observability / Monitoring ---
variable "enable_monitoring" {
  description = "Toggle for enhanced monitoring, dashboards, and alarms"
  type        = bool
  default     = true
}

# --- Optional / Advanced (Can be injected via modules outputs) ---
variable "route53_zone_id" {
  description = "Route 53 Hosted Zone ID for DNS records"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ACM Certificate ARN for HTTPS (CloudFront / ALB)"
  type        = string
  default     = ""
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch metrics"
  type        = string
  default     = ""
}

variable "eks_oidc_issuer_url" {
  description = "EKS OIDC provider URL for IRSA roles"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "KMS Key ARN for encrypting secrets and X-Ray"
  type        = string
  default     = ""
}