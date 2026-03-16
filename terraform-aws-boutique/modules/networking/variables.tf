# --- modules/networking/variables.tf ---

variable "project_name" {
  description = "Name of the project used for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the 3 public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for the 3 private app subnets (EKS Nodes)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for the 3 private database subnets (Redis/RDS)"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

variable "cluster_name" {
  description = "The name of the EKS cluster for tagging purposes"
  type        = string
}


variable "certificate_arn" {
  description = "The ARN of the SSL certificate for CloudFront"
  type        = string
}

variable "domain_name" {
  description = "The primary domain name for the application (e.g., example.com)"
  type        = string
}
variable "alb_dns_name" {
  description = "The DNS name of the ALB"
  type        = string
  default     = "" # Standard practice: allow it to be empty initially
}
variable "waf_arn" {
  description = "WAF ARN to attach to CloudFront"
  type        = string
}


