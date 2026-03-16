# --- modules/compute/main.tf ---

# 1. EKS Cluster Definition
resource "aws_eks_cluster" "main" {           #This creates a Kubernetes control plane using Amazon Elastic Kubernetes Service.The control plane includes: Kubernetes API server etcd database scheduler controller manager AWS manages this for you. So you do not manage master nodes yourself.
  name     = "${var.project_name}-cluster"
  role_arn = var.eks_cluster_role_arn
  version  = "1.29"

  vpc_config {
    subnet_ids              = var.private_app_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
  }

  tags = {
    Name = "${var.project_name}-eks"  
    Env  = var.environment
  }
}

# 2. Managed Node Group (The Worker Nodes)
resource "aws_eks_node_group" "main" {    #This creates the worker nodes where your containers run.
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.private_app_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
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
data "tls_certificate" "eks" {     #This fetches the OIDC certificate fingerprint from the EKS cluster.  AWS requires this fingerprint when creating the OIDC provider
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {    #This enables IRSA (IAM Roles for Service Accounts). IRSA allows Kubernetes pods to access AWS services securely.
  client_id_list  = ["sts.amazonaws.com"]   #This means the identity provider trusts AWS STS. STS is AWS Security Token Service. STS is used to: AssumeRole Generate temporary credentials
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]    #AWS must verify the TLS certificate of the OIDC provider.
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer    #This is the OIDC issuer URL provided by EKS. It looks like: https://oidc.eks.<region>.amazonaws.com/id/<eks-cluster-id>
}