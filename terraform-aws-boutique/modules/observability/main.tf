# --- modules/observability/main.tf ---

# 1. Centralized Log Group for EKS Microservices
# This will hold logs for all 11 services (frontend, paymentservice, etc.)
resource "aws_cloudwatch_log_group" "eks_logs" {
  name              = "/aws/eks/${var.project_name}/cluster"
  retention_in_days = 30 # Industry Standard: Balance between history and cost

  tags = {
    Name = "${var.project_name}-logs"
    Env  = var.environment
  }
}

# 2. CloudWatch Dashboard
# Senior level: Providing a "Single Pane of Glass" for the SRE team
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-overview"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "Frontend Latency (ALB)"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix]
          ]
          period = 300
          stat   = "Sum"
          region = var.region
          title  = "Frontend 5XX Errors"
        }
      }
    ]
  })
}

# 3. CloudWatch Alarm: High Error Rate
# If your microservices start failing, this triggers an SNS notification
resource "aws_cloudwatch_metric_alarm" "high_error_rate" {
  alarm_name          = "${var.project_name}-high-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors microservice 5XX errors"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
}