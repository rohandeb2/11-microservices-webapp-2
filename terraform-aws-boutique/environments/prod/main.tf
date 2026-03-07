# --- environments/prod/main.tf ---

terraform {
  required_version = ">= 1.5.0"
  # Production state must be isolated in its own bucket/key
  backend "s3" {} 
}

provider "aws" {
  region = var.aws_region

  # Senior Level: Default tags for all production resources
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "prod"
      ManagedBy   = "Terraform"
      Owner       = "SRE-Team"
    }
  }
}

# 1. Global Layer (Governance)
module "global_iam" {
  source       = "../../global/iam-users"
  project_name = var.project_name
}

# 2. Networking Layer (High Availability)
module "networking" {
  source        = "../../modules/networking"
  project_name  = var.project_name
  environment   = "prod"
  vpc_cidr      = var.vpc_cidr
  domain_name   = var.domain_name
  
  # Multi-AZ is enforced by variables in prod.tfvars
  alb_dns_name  = module.compute.alb_dns_name
  alb_zone_id   = module.compute.alb_zone_id
}

# 3. Security Layer (Hardened)
module "security" {
  source              = "../../modules/security"
  project_name        = var.project_name
  environment         = "prod"
  region              = var.aws_region
  domain_name         = var.domain_name
  route53_zone_id     = module.networking.route53_zone_id
  eks_oidc_issuer_url = module.compute.eks_oidc_issuer_url
}

# 4. Compute Layer (Scaled Out)
module "compute" {
  source                 = "../../modules/compute"
  project_name           = var.project_name
  environment            = "prod"
  vpc_id                 = module.networking.vpc_id
  public_subnet_ids      = module.networking.public_subnets
  private_app_subnet_ids = module.networking.private_app_subnets
  eks_cluster_role_arn   = module.security.eks_cluster_role_arn
  eks_node_role_arn      = module.security.eks_node_role_arn
  certificate_arn        = module.security.certificate_arn
  kms_key_arn            = module.security.kms_key_arn
  
  # Prod specific: Larger instance types passed via variables
  instance_types         = var.eks_instance_types
}

# 5. Data Layer (Durable)
module "data" {
  source                      = "../../modules/data"
  project_name                = var.project_name
  environment                 = "prod"
  vpc_id                      = module.networking.vpc_id
  private_db_subnet_ids       = module.networking.private_db_subnets
  eks_nodes_sg_id             = module.compute.eks_nodes_sg_id
  kms_key_arn                 = module.security.kms_key_arn
  cloudfront_distribution_arn = module.networking.cloudfront_arn
}

# 6. Messaging & Observability
module "messaging" {
  source          = "../../modules/messaging"
  project_name    = var.project_name
  environment     = "prod"
  kms_key_arn     = module.security.kms_key_arn
  email_queue_arn = module.messaging.email_queue_arn
}

module "observability" {
  source             = "../../modules/observability"
  project_name       = var.project_name
  environment        = "prod"
  region             = var.aws_region
  alb_arn_suffix     = module.compute.alb_arn_suffix
  sns_topic_arn      = module.messaging.order_topic_arn
  kms_key_arn        = module.security.kms_key_arn
  eks_node_role_name = module.security.eks_node_role_name
}