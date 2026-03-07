# --- global/iam-users/variables.tf ---

variable "project_name" {
  description = "The name of the project for tagging and naming"
  type        = string
  default     = "boutique-app"
}

variable "admin_users" {
  description = "List of IAM usernames to create with Admin access"
  type        = list(string)
  default     = ["rohan-devops"]
}

variable "developer_users" {
  description = "List of IAM usernames to create with ReadOnly access"
  type        = list(string)
  default     = []
}