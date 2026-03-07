# --- modules/messaging/variables.tf ---

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "kms_key_arn" {
  description = "KMS ARN for encrypting messages"
  type        = string
}
# --- Add to modules/messaging/variables.tf ---

# Ensure var.project_name and var.environment are already present