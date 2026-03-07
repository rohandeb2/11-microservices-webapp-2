# --- modules/observability/variables.tf ---

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "alb_arn_suffix" {
  description = "The ARN suffix of the ALB for metric tracking"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS Topic ARN for sending alerts (from messaging module)"
  type        = string
}
# --- Add to modules/observability/variables.tf ---

variable "kms_key_arn" {
  description = "KMS ARN from security module for X-Ray encryption"
  type        = string
}

variable "eks_node_role_name" {
  description = "The name of the IAM role for EKS worker nodes"
  type        = string
}