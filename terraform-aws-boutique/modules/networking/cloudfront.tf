

# --- modules/networking/cloudfront.tf ---

resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront for ${var.project_name} frontend"
  default_root_object = ""

  # Origin: This points to your Application Load Balancer (ALB)
  origin {
    domain_name = var.alb_dns_name
    origin_id   = "ALB-Frontend"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # Change to "https-only" once ACM is ready
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ALB-Frontend"

    forwarded_values {
      query_string = true
      headers      = ["Host", "Origin", "Authorization"] # Mandatory for microservices headers

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100" # Cost optimization for Dev/SIT environments

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    # Once you have ACM:
    # acm_certificate_arn = var.certificate_arn
    # ssl_support_method  = "sni-only"
  }

  tags = {
    Name = "${var.project_name}-cloudfront"
    Env  = var.environment
  }
}