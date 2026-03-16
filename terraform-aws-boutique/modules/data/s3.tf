# --- modules/data/s3.tf ---

# 1. Main Application Assets Bucket
resource "aws_s3_bucket" "assets" {
  bucket = "${var.project_name}-assets-${var.environment}-${random_id.suffix.hex}"

  # Industry Standard: Prevent accidental deletion of the bucket
  lifecycle {
    prevent_destroy = false # Set to true for Production
  }

  tags = {
    Name = "${var.project_name}-assets"
    Env  = var.environment
  }
}

# 2. Enable Versioning
# Critical for recovery if products.json is accidentally overwritten or deleted
resource "aws_s3_bucket_versioning" "assets_versioning" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 3. Default Server-Side Encryption
# Using the Customer Managed Key from our security module
resource "aws_s3_bucket_server_side_encryption_configuration" "assets_encryption" {
  bucket = aws_s3_bucket.assets.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# 4. Block Public Access
# Industry Standard: S3 buckets should NEVER be public. Use CloudFront to serve data.
resource "aws_s3_bucket_public_access_block" "assets_access" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 5. Bucket Policy for CloudFront Access (OAC)
# This allows CloudFront to fetch images while keeping the bucket private
resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.assets.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.assets.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = var.cloudfront_distribution_arn
          }
        }
      }
    ]
  })
}


resource "aws_s3_bucket_ownership_controls" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}