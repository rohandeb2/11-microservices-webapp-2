# --- modules/messaging/main.tf ---

# 1. Amazon SNS Topic (The Event Bus)
# This topic will broadcast "Order Placed" events
resource "aws_sns_topic" "order_events" {
  name              = "${var.project_name}-order-events"
  kms_master_key_id = var.kms_key_arn # Encrypting messages at rest

  tags = {
    Name = "${var.project_name}-sns"
  }
}

# 3. Dead Letter Queue (DLQ)
# Industry Standard: Always have a place for "poison" messages to go
resource "aws_sqs_queue" "email_dlq" {
  name              = "${var.project_name}-email-dlq"
  kms_master_key_id = var.kms_key_arn
}

# 2. Amazon SQS Queue (The Worker Queue)
# This queue will hold messages for the emailservice to process
resource "aws_sqs_queue" "email_queue" {
  name                      = "${var.project_name}-email-queue"
  message_retention_seconds = 86400 # 1 Day
  receive_wait_time_seconds = 20    # Enable Long Polling (Cost Optimization)
  kms_master_key_id         = var.kms_key_arn

  # Dead Letter Queue configuration for handling failed messages
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.email_dlq.arn
    maxReceiveCount     = 5 # Retry 5 times before moving to DLQ
  })

  tags = {
    Name = "${var.project_name}-sqs"
  }
}



# 4. SNS to SQS Subscription
# Automatically push order events into the email queue
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.order_events.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.email_queue.arn
  raw_message_delivery = true
}

# 5. SQS Policy to allow SNS to write to it
resource "aws_sqs_queue_policy" "allow_sns" {
  queue_url = aws_sqs_queue.email_queue.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "sns.amazonaws.com"
      }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.email_queue.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_sns_topic.order_events.arn
        }
      }
    }]
  })
}