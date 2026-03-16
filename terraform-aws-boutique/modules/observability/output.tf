# --- modules/observability/outputs.tf ---

output "log_group_name" {
  description = "The name of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.eks_logs.name
}

# output "dashboard_arn" {
#   description = "The ARN of the CloudWatch Dashboard"
#   value       = aws_cloudwatch_dashboard.main.dashboard_arn #
# }
output "dashboard_name" {
  description = "The name of the CloudWatch Dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}
# --- Add to modules/observability/outputs.tf ---

output "xray_sampling_rule_arn" {
  description = "The ARN of the X-Ray sampling rule"
  value       = aws_xray_sampling_rule.main.arn
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.eks_logs.arn
}