# --- modules/compute/fargate.tf ---

# 1. IAM Role for Fargate Pods
# Fargate pods need their own execution role to pull images and log to CloudWatch
resource "aws_iam_role" "fargate" {
  name = "${var.project_name}-fargate-execution-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"         #This allows the EKS Fargate service to assume this role when running pods on Fargate.
      Effect = "Allow"                   #This means that the action of assuming this role is allowed. If this were set to "Deny", then no one would be able to assume this role, which would break the Fargate pods' ability to function.
      Principal = {     #This allows the EKS Fargate service to assume this role when running pods on Fargate.
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "fargate_execution" {    #This attaches the necessary AWS managed policy to the Fargate execution role, allowing it to pull container images from ECR and write logs to CloudWatch.
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate.name  #This references the name of the IAM role we just created for Fargate pods.
}

# 2. Fargate Profile
# Industry Standard: We isolate Fargate workloads into a specific namespace
resource "aws_eks_fargate_profile" "main" {           #This module enables serverless Kubernetes pods using ,AWS Fargate with ,Amazon Elastic Kubernetes Service.
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "${var.project_name}-fargate-profile"
  pod_execution_role_arn = aws_iam_role.fargate.arn  #This is the IAM role that Fargate pods will assume to pull container images and write logs. It must have the AmazonEKSFargatePodExecutionRolePolicy attached, which we set up in the previous step.
  subnet_ids             = var.private_app_subnet_ids

  selector {
    namespace = "boutique-app"
  }
  depends_on = [
  aws_iam_role_policy_attachment.fargate_execution
]
  tags = {
    Name = "${var.project_name}-fargate"
    Env  = var.environment
  }
}