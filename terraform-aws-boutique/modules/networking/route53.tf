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

  alias {     #In Amazon Route 53, an Alias record is a special DNS record that allows a domain to point directly to AWS services.
    # Reference the resource directly to create an implicit dependency
    name                   = aws_cloudfront_distribution.main.domain_name      #This line tells Route53 where to send the traffic.
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id     #Every AWS service that integrates with Route53 has a Hosted Zone ID. 
                                                                                  #For Amazon CloudFront, AWS uses a special global hosted zone.
                                                                                  # This tells Route53 exactly which AWS service to route to
    evaluate_target_health = false           #Route53 will not check the health of the CloudFront distribution before routing traffic.
  }
}

