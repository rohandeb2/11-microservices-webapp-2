# --- Project Context ---
variable "project_name" {
  description = "Project name used for resource naming and billing tags"
  type        = string
}

variable "environment" {
  description = "Environment identifier (set to 'prod')"
  type        = string
}

variable "aws_region" {
  description = "The AWS region for the production deployment"
  type        = string
}

# --- Networking ---
variable "vpc_cidr" {
  description = "The primary CIDR block for the production VPC"
  type        = string
}

variable "domain_name" {
  description = "The root production domain (e.g., rohandevops.shop)"
  type        = string
}

# --- Compute (EKS) ---
variable "eks_instance_type" {
  description = "The EC2 instance type for production worker nodes (e.g., m5.large)"
  type        = string
}

variable "eks_node_count" {
  description = "The number of worker nodes to maintain for high availability"
  type        = number
}

# --- Security ---
variable "enable_security_hub" {
  description = "Boolean to ensure Security Hub is active for compliance"
  type        = bool
}

# --- Data Layer ---
variable "redis_node_type" {
  description = "The instance class for production ElastiCache nodes"
  type        = string
}

variable "redis_node_count" {
  description = "The number of nodes in the Redis cluster (e.g., 3 for Multi-AZ)"
  type        = number
}

# --- Observability ---
variable "enable_monitoring" {
  description = "Enable high-resolution monitoring and production alarms"
  type        = bool
}