# --- modules/security/lbc-irsa.tf ---

# 1. Get current AWS account ID
data "aws_caller_identity" "current" {}

# 2. Fetch EKS cluster details
data "aws_eks_cluster" "main" {
  name = "${var.project_name}-cluster"
}

# 3. Clean OIDC URL
locals {
  oidc_clean = replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")
}

# 4. IAM Role for AWS Load Balancer Controller (IRSA)
resource "aws_iam_role" "lbc_role" {
  name = "${var.project_name}-aws-load-balancer-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"

        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_clean}"
        }

        Condition = {
          StringEquals = {
            "${local.oidc_clean}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
            "${local.oidc_clean}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-lbc-role"
    Env  = var.environment
  }
}

# 5. Attach AWS Load Balancer Controller Policy
resource "aws_iam_role_policy_attachment" "lbc_policy_attach" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/AWSLoadBalancerControllerIAMPolicy"
  role       = aws_iam_role.lbc_role.name
}

# 6. Kubernetes Service Account for the controller
resource "kubernetes_service_account" "lbc_sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.lbc_role.arn
    }
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}