# --- modules/messaging/eventbridge.tf ---

# 1. Custom Event Bus
# Industry Standard: Avoid using the 'default' bus for application-specific logic
resource "aws_cloudwatch_event_bus" "app_bus" {
  name = "${var.project_name}-event-bus"

  tags = {
    Name = "${var.project_name}-bus"
    Env  = var.environment
  }
}

# 2. EventBridge Rule: Scheduled Cleanup
# Triggers every 24 hours to clear expired carts or temporary data
resource "aws_cloudwatch_event_rule" "daily_cleanup" {
  name                = "${var.project_name}-daily-cleanup"
  description         = "Trigger daily cleanup tasks for microservices"
  schedule_expression = "rate(24 hours)"
}

# 3. EventBridge Target: Trigger a specific SQS Queue
# We can route events to the Email Queue for notification of cleanup
resource "aws_cloudwatch_event_target" "cleanup_target" {
  rule           = aws_cloudwatch_event_rule.daily_cleanup.name
  target_id      = "SendToEmailQueue"
  arn       = aws_sqs_queue.email_queue.arn

  # Industry Standard: Input Transformation
  # We send a specific JSON message to the microservice
  input_transformer {
    input_paths = {
      time = "$.time"
    }
    input_template = <<EOF
{
  "action": "CLEANUP_EXPIRED_DATA",
  "triggered_at": <time>,
  "service": "all"
}
EOF
  }
}

# 4. EventBridge Archive
# Senior Level: This allows you to "Replay" events if a microservice fails
resource "aws_cloudwatch_event_archive" "order_archive" {
  name             = "${var.project_name}-order-archive"
  event_source_arn = aws_cloudwatch_event_bus.app_bus.arn
  retention_days   = 7
}