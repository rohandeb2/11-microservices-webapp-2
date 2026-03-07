# --- modules/compute/variables.tf ---

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  description = "VPC ID from the networking module"
  type        = string
}

variable "private_app_subnet_ids" {
  description = "Private subnets for nodes and pods"
  type        = list(string)
}

variable "eks_cluster_role_arn" {
  description = "IAM Role ARN for the EKS Cluster"
  type        = string
}

variable "eks_node_role_arn" {
  description = "IAM Role ARN for the Worker Nodes"
  type        = string
}
# --- Add to modules/compute/variables.tf ---

variable "cluster_name" {
  description = "Name of the EKS cluster (referenced from main.tf)"
  type        = string
}

# private_app_subnet_ids, project_name, and environment 
# should already be present from the previous step.

# --- Add to modules/compute/variables.tf ---

variable "kms_key_arn" {
  description = "ARN of the KMS key for ECR encryption"
  type        = string
}

# Ensure var.project_name and var.environment are already defined
# --- Add to modules/compute/variables.tf ---

variable "public_subnet_ids" {
  description = "Public subnets for the ALB"
  type        = list(string)
}

variable "certificate_arn" {
  description = "SSL Certificate ARN from security module"
  type        = string
}

# vpc_id, project_name, and environment should already be defined