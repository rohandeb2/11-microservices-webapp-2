# --- modules/security/variables.tf ---

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "dev, staging, or prod"
  type        = string
}

variable "region" {
  description = "AWS region for security hub standards"
  type        = string
}

variable "enable_security_hub" {
  description = "Toggle to enable/disable Security Hub"
  type        = bool
  default     = true
}

# --- Add to modules/security/variables.tf ---


# Note: No specific KMS variables are needed here as we use project defaults,
# but keeping project_name and environment is mandatory for naming logic.


# --- Add to modules/security/variables.tf ---

variable "eks_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  type        = string
}


# --- Add to modules/security/variables.tf ---



# Ensure var.project_name and var.environment are already defined as per previous steps

# --- Add to modules/security/variables.tf ---

variable "domain_name" {
  description = "The primary domain name (e.g., example.com) for the certificate"
  type        = string
}

variable "route53_zone_id" {
  description = "The Route 53 Hosted Zone ID used for DNS validation"
  type        = string
}