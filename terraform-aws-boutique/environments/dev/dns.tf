# --- environments/dev/dns.tf ---

resource "aws_route53_record" "alb_alias" {
  # Change: Reference the networking module output
  zone_id = module.networking.route53_zone_id 
  
  name    = "api.${var.domain_name}"
  type    = "A"

  alias {
    # Change: Reference the compute module outputs
    name                   = module.compute.alb_dns_name
    zone_id                = module.compute.alb_zone_id
    evaluate_target_health = true
  }
}