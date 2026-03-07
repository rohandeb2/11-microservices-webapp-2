# --- Project Context ---
variable "project_name" {
  description = "The name of the project used for naming and tagging"
  type        = string
}

variable "environment" {
  description = "The deployment environment (dev/prod)"
  type        = string
}

variable "aws_region" {
  description = "The AWS region where resources will be deployed"
  type        = string
}

# --- Networking ---
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "domain_name" {
  description = "The primary domain name for the application"
  type        = string
}

# --- Compute (EKS) ---
variable "eks_instance_type" {
  description = "The EC2 instance type for EKS worker nodes"
  type        = string
}

variable "eks_node_count" {
  description = "Number of worker nodes in the EKS cluster"
  type        = number
}

# --- Security ---
variable "enable_security_hub" {
  description = "Toggle to enable or disable AWS Security Hub"
  type        = bool
}

# --- Data Layer ---
variable "redis_node_type" {
  description = "The instance class for ElastiCache Redis nodes"
  type        = string
}

variable "redis_node_count" {
  description = "Number of nodes in the Redis replication group"
  type        = number
}

# --- Observability ---
variable "enable_monitoring" {
  description = "Toggle for enhanced monitoring and alarms"
  type        = bool
}