# --- modules/data/athena.tf ---

# 1. Athena Database
# This creates a logical grouping for your microservices log tables
resource "aws_athena_database" "logs" {
  name   = "${replace(var.project_name, "-", "_")}_logs_db"   #Athena does NOT allow "-"
  bucket = aws_s3_bucket.athena_results.id          #This is the S3 bucket where Athena will store query results. It must be in the same region as your Athena workgroup.
}

# 2. Athena Workgroup
# Industry Standard: Workgroups are used to isolate queries and enforce cost/limit constraints
resource "aws_athena_workgroup" "main" {
  name = "${var.project_name}-workgroup"

  configuration {
    enforce_workgroup_configuration    = true # This ensures that all queries run with the settings defined in this workgroup, preventing users from overriding them and potentially incurring unexpected costs.
    publish_cloudwatch_metrics_enabled = true # This allows you to monitor query performance and costs in CloudWatch, which is essential for optimizing your Athena usage and keeping costs under control.

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
  bucket        = bucket = "${var.project_name}-athena-results-${var.environment}-${random_id.suffix.hex}"
  force_destroy = force_destroy = var.environment != "prod" # In non-prod environments, we allow Terraform to delete the bucket and all its contents when destroying infrastructure. In production, we set this to false to prevent accidental data loss, requiring manual cleanup of query results if needed.
}

resource "aws_s3_bucket_public_access_block" "athena_results_block" {
  bucket = aws_s3_bucket.athena_results.id

  block_public_acls       = true  # This prevents the creation of ACLs that would allow public access to the bucket, ensuring that your Athena query results are not accidentally exposed to the internet.
  block_public_policy    = true  # This prevents the attachment of bucket policies that would allow public access, adding an extra layer of protection against misconfigurations that could lead to data exposure.
  ignore_public_acls      = true # This tells AWS to ignore any ACLs that grant public access, ensuring that even if such ACLs are created, they will not take effect and the bucket remains secure.
  restrict_public_buckets = true # This restricts the bucket from being made public, even if a policy or ACL is applied that would allow public access. It ensures that the bucket cannot be exposed to the internet under any circumstances, which is crucial for protecting sensitive data stored in Athena query results.  
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

resource "aws_s3_bucket_versioning" "athena_results_versioning" {
  bucket = aws_s3_bucket.athena_results.id

  versioning_configuration {
    status = "Enabled"
  }
}