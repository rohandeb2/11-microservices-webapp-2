# --- modules/networking/route53.tf ---

# 1. Create the Public Hosted Zone for your domain
resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = {
    Name = "${var.project_name}-hosted-zone"
    Env  = var.environment
  }
}

# 2. Create an Alias Record pointing to CloudFront
resource "aws_route53_record" "frontend_alias" {
  # FIX: Reference the zone created above, not an external variable
  zone_id = aws_route53_zone.main.zone_id 
  name    = var.domain_name
  type    = "A"

  alias {
    # Reference the resource directly to create an implicit dependency
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}

