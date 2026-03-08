# --- modules/security/acm.tf ---

# 1. Request the SSL Certificate in us-east-1
# Industry Standard: CloudFront strictly requires certificates to be in the us-east-1 region.
resource "aws_acm_certificate" "cert" {
  # This uses the us-east-1 provider alias passed from the root main.tf
  provider          = aws.us_east_1 
  domain_name       = var.domain_name
  validation_method = "DNS"

  # Wildcard support for subdomains like shop.rohandevops.co.in
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
# Note: DNS records are global, so we use the default provider here
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
# This MUST use the same us-east-1 provider as the certificate request
resource "aws_acm_certificate_validation" "cert" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  timeouts {
    create = "10m" 
  }
}