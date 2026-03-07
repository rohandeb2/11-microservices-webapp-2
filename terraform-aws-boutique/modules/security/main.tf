# --- modules/security/main.tf ---

# 1. AWS WAF (Web Application Firewall) 
# Scope is set to CLOUDFRONT to protect the global entry point of your 11 microservices
resource "aws_wafv2_web_acl" "main" {
  name     = "${var.project_name}-waf-${var.environment}"
  scope    = "CLOUDFRONT"
  description = "WAF for ${var.project_name} CloudFront Distribution"

  default_action {
    allow {}
  }

  # Industry Standard: AWS Managed Rules (Common Rule Set)
  # Protects against common vulnerabilities like SQL Injection and local file inclusion
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # Known Bad Inputs Rule Set
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-waf-main-metric"
    sampled_requests_enabled   = true
  }

  tags = {
    Name = "${var.project_name}-waf"
    Env  = var.environment
  }
}

# 2. AWS Security Hub
# Mandatory for MNCs to maintain a security score and detect misconfigurations
resource "aws_securityhub_account" "main" {
  count = var.enable_security_hub ? 1 : 0
}

# Industry Standard: Enabling the Foundational Security Best Practices standard
resource "aws_securityhub_standards_subscription" "foundational" {
  count         = var.enable_security_hub ? 1 : 0
  depends_on    = [aws_securityhub_account.main]
  standards_arn = "arn:aws:securityhub:${var.region}:850927603755:standards/aws-foundational-security-best-practices/v/1.0.0"
}


# 4. IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster" {
  name = "${var.project_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# 5. IAM Role for EKS Worker Nodes
resource "aws_iam_role" "eks_nodes" {
  name = "${var.project_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Essential policies for worker nodes to function
resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

# 6. Secrets Manager for App Credentials
resource "aws_secretsmanager_secret" "main" {
  name       = "${var.project_name}-secrets"
  kms_key_id = aws_kms_key.main.arn
}