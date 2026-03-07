# --- modules/data/variables.tf ---

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_db_subnet_ids" {
  description = "Subnet IDs for the isolated database layer"
  type        = list(string)
}

variable "eks_nodes_sg_id" {
  description = "Security Group ID of the EKS nodes to allow access"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS ARN for at-rest encryption"
  type        = string
}


variable "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution to allow access"
  type        = string
}
