# --- environments/dev/dns.tf ---
resource "aws_route53_record" "alb_alias" {
  # FIX: Reference the module output, not the internal resource
  zone_id = module.networking.route53_zone_id 
  
  name    = "api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = module.compute.alb_dns_name
    zone_id                = module.compute.alb_zone_id
    evaluate_target_health = true
  }
}