# --- modules/messaging/outputs.tf ---

output "order_topic_arn" {
  description = "ARN of the SNS Topic for orders"
  value       = aws_sns_topic.order_events.arn
}

output "email_queue_url" {
  description = "URL of the SQS Email Queue"
  value       = aws_sqs_queue.email_queue.id
}

output "email_queue_arn" {
  description = "ARN of the SQS Email Queue"
  value       = aws_sqs_queue.email_queue.arn
}
# --- Add to modules/messaging/outputs.tf ---

output "event_bus_arn" {
  description = "The ARN of the custom EventBridge bus"
  value       = aws_cloudwatch_event_bus.app_bus.arn
}

output "event_bus_name" {
  description = "The name of the custom EventBridge bus"
  value       = aws_cloudwatch_event_bus.app_bus.name
}
output "email_dlq_arn" {
  description = "ARN of the Email Dead Letter Queue"
  value       = aws_sqs_queue.email_dlq.arn
}
output "email_queue_name" {
  value = aws_sqs_queue.email_queue.name
}