# # --- 1. Data Sources: Fetching Cluster & OIDC Info ---
# # Replace "boutique-cluster" with your actual EKS cluster name
# data "aws_eks_cluster" "main" {
#   name = "boutique-app-cluster" 
# }

# # --- 2. IAM Role for Load Balancer Controller ---
# resource "aws_iam_role" "lbc_role" {
#   name = "AmazonEKSLoadBalancerControllerRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Effect = "Allow"
#         Principal = {
#           Federated = "arn:aws:iam::889501007925:oidc-provider/${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"
#         }
#         Condition = {
#           StringEquals = {
#             "${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
#           }
#         }
#       }
#     ]
#   })
# }

# # --- 3. Attach the Policy ---
# resource "aws_iam_role_policy_attachment" "lbc_policy_attach" {
#   policy_arn = "arn:aws:iam::889501007925:policy/AWSLoadBalancerControllerIAMPolicy"
#   role       = aws_iam_role.lbc_role.name
# }

# # --- 4. Kubernetes Service Account ---
# resource "kubernetes_service_account" "lbc_sa" {
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.lbc_role.arn
#     }
#   }

#   lifecycle {
#     ignore_changes = [metadata[0].annotations]
#   }
# }