# --- modules/compute/fargate.tf ---

# 1. IAM Role for Fargate Pods
# Fargate pods need their own execution role to pull images and log to CloudWatch
resource "aws_iam_role" "fargate" {
  name = "${var.project_name}-fargate-execution-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "fargate_execution" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate.name
}

# 2. Fargate Profile
# Industry Standard: We isolate Fargate workloads into a specific namespace
resource "aws_eks_fargate_profile" "main" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "${var.project_name}-fargate-profile"
  pod_execution_role_arn = aws_iam_role.fargate.arn
  subnet_ids             = var.private_app_subnet_ids

  selector {
    namespace = "fargate-node"
  }

  tags = {
    Name = "${var.project_name}-fargate"
    Env  = var.environment
  }
}