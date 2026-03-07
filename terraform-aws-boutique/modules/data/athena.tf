# --- modules/data/athena.tf ---

# 1. Athena Database
# This creates a logical grouping for your microservices log tables
resource "aws_athena_database" "logs" {
  name   = "${replace(var.project_name, "-", "_")}_logs_db"
  bucket = aws_s3_bucket.athena_results.id
}

# 2. Athena Workgroup
# Industry Standard: Workgroups are used to isolate queries and enforce cost/limit constraints
resource "aws_athena_workgroup" "main" {
  name = "${var.project_name}-workgroup"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/output/"
      
      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = var.kms_key_arn
      }
    }
  }

  tags = {
    Name = "${var.project_name}-athena-wg"
  }
}

# 3. S3 Bucket for Athena Query Results
# Athena needs a place to store the results of every SQL query you run
resource "aws_s3_bucket" "athena_results" {
  bucket        = "${var.project_name}-athena-results-${var.environment}"
  force_destroy = true # Good for dev; set to false for production
}

resource "aws_s3_bucket_public_access_block" "athena_results_block" {
  bucket = aws_s3_bucket.athena_results.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "athena_results_encryption" {
  bucket = aws_s3_bucket.athena_results.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}