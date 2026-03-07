output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_app_subnets" {
  value = aws_subnet.private_app[*].id
}

output "private_db_subnets" {
  value = aws_subnet.private_db[*].id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

# output "aws_cloudfront_distribution" {
#   # Ensure this matches the resource name in your main.tf
#   value = aws_cloudfront_distribution.main.arn
# }

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.main.domain_name
}

output "route53_zone_id" {
  value = aws_route53_zone.main.zone_id
}

output "cloudfront_arn" {
  value = aws_cloudfront_distribution.main.arn
}


# --- modules/networking/outputs.tf --