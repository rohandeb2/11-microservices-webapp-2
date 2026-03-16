# Project details
variable "project_name" {
  description = "The name of the project for naming and tagging resources"
  type        = string
  default     = "boutique-app"
}

variable "environment" {
  description = "The environment (dev, staging, prod) for tagging and naming"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "ap-south-1"
}

# KMS key ARN/ID used for Terraform deployer least privilege policy
variable "kms_key_id" {
  description = "The KMS key ID/ARN for project encryption"
  type        = string
}