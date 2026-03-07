# --- modules/compute/main.tf ---

# 1. EKS Cluster Definition
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-cluster"
  role_arn = var.eks_cluster_role_arn
  version  = "1.29"

  vpc_config {
    subnet_ids              = var.private_app_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
  }

  tags = {
    Name = "${var.project_name}-eks"
    Env  = var.environment
  }
}

# 2. Managed Node Group (The Worker Nodes)
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.private_app_subnet_ids

  scaling_config {
    desired_size = 3
    max_size     = 6
    min_size     = 2
  }

  instance_types = [var.environment == "prod" ? "m7i-flex.large" : "m7i-flex.large"]
  capacity_type  = "ON_DEMAND" # Use "SPOT" for cost optimization in dev

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name = "${var.project_name}-node"
  }
}

# 3. Security Group for Cluster
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.project_name}-eks-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-cluster-sg"
  }
}

# 4. OIDC Provider - Required for IRSA (IAM Roles for Service Accounts)
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}