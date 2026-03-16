# --- modules/observability/xray.tf ---

# 1. X-Ray Sampling Rule
# Industry Standard: We don't trace 100% of requests in production to save costs.
# We trace a "reservoir" of 1 request per second and 5% of all other requests.
resource "aws_xray_sampling_rule" "main" {
  rule_name      = "${var.project_name}-sampling-rule"
  priority       = 1000
  version        = 1
  reservoir_size = 1
  fixed_rate     = 0.05
  url_path       = "*"
  host           = "*"
  http_method    = "*"
  service_name   = "*"
  service_type   = "*"
  resource_arn   = "*"

  attributes = {
    Environment = var.environment
  }
}

# 2. X-Ray Encryption
# Ensuring our trace data is encrypted using our Customer Managed Key (KMS)
resource "aws_xray_encryption_config" "main" {
  type       = "KMS"
  key_id     = var.kms_key_arn
  lifecycle {
  prevent_destroy = true
}
}

# 3. IAM Policy for EKS Worker Nodes to write to X-Ray
# This allows the X-Ray daemon running in your EKS cluster to send data to AWS
resource "aws_iam_policy" "xray_write" {
  name        = "${var.project_name}-xray-write"
  description = "Allows EKS nodes to send traces to AWS X-Ray"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets",
          "xray:GetSamplingStatisticSummaries"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "xray_attach" {
  role       = var.eks_node_role_name
  policy_arn = aws_iam_policy.xray_write.arn
}