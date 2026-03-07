# --- modules/security/acm.tf ---

# 1. Request the SSL Certificate
# Industry Standard: CloudFront requires certificates to be in the us-east-1 region
resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  # Include a wildcard to cover subdomains like api.example.com or shop.example.com
  subject_alternative_names = ["*.${var.domain_name}"]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-certificate"
    Env  = var.environment
  }
}

# 2. Create DNS Validation Records in Route 53
# This automates the "Proof of Ownership" step
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
}

# 3. Trigger the actual Validation process
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  # SENIOR TIP: Add a timeout so Terraform doesn't hang forever
  timeouts {
    create = "10m" 
  }
}