# --- environments/dev/main.tf ---

terraform {
  required_version = ">= 1.5.0"
  # Backend is initialized via backend.conf for flexibility
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1" # Required for WAF (CloudFront) and ACM (CloudFront)
}

locals {
  # Define the name ONCE here
  cluster_name = "${var.project_name}-${var.environment}-cluster"
}

# 1. Global Layer (Human Access)
module "global_iam" {
  source       = "../../global/iam-users"
  project_name = var.project_name
}

# 2. Networking Layer (The Foundation)
module "networking" {
  source        = "../../modules/networking"
  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
  project_name  = var.project_name
  environment   = var.environment
  vpc_cidr      = var.vpc_cidr
  domain_name   = var.domain_name
  
  # Received from compute after ALB is created
  cluster_name = local.cluster_name 
  # certificate_arn is needed if your networking module handles CloudFront/ALB HTTPS
  certificate_arn = module.security.certificate_arn
  alb_dns_name = module.compute.alb_dns_name
  waf_arn = module.security.waf_arn
}

# 3. Security Layer (The Guardrail)
module "security" {
  source              = "../../modules/security"
  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
  project_name        = var.project_name
  environment         = var.environment
  region              = var.aws_region
  domain_name         = var.domain_name
  route53_zone_id     = module.networking.route53_zone_id
  eks_oidc_issuer_url = module.compute.eks_oidc_issuer_url
}

# 4. Compute Layer (The Brain)
module "compute" {
  source                 = "../../modules/compute"
  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.networking.vpc_id
  public_subnet_ids      = module.networking.public_subnets
  private_app_subnet_ids = module.networking.private_app_subnets
  eks_cluster_role_arn   = module.security.eks_cluster_role_arn
  eks_node_role_arn      = module.security.eks_node_role_arn
  certificate_arn        = module.security.certificate_arn
  kms_key_arn            = module.security.kms_key_arn
  cluster_name = local.cluster_name
}

# 5. Data Layer (The Memory)
module "data" {
  source                      = "../../modules/data"
  project_name                = var.project_name
  environment                 = var.environment
  vpc_id                      = module.networking.vpc_id
  private_db_subnet_ids       = module.networking.private_db_subnets
  eks_nodes_sg_id             = module.compute.eks_nodes_sg_id
  kms_key_arn                 = module.security.kms_key_arn
  cloudfront_distribution_arn = module.networking.cloudfront_arn
}

# 6. Messaging Layer (The Nervous System)
module "messaging" {
  source          = "../../modules/messaging"
  project_name    = var.project_name
  environment     = var.environment
  kms_key_arn     = module.security.kms_key_arn
}

# 7. Observability Layer (The Eyes)
module "observability" {
  source             = "../../modules/observability"
  project_name       = var.project_name
  environment        = var.environment
  region             = var.aws_region
  alb_arn_suffix     = module.compute.alb_arn_suffix
  sns_topic_arn      = module.messaging.order_topic_arn
  kms_key_arn        = module.security.kms_key_arn
  eks_node_role_name = module.security.eks_node_role_name
}