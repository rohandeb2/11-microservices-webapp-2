# --- modules/data/outputs.tf ---

output "redis_primary_endpoint" {
  description = "Primary endpoint for Redis (used by cartservice)"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_port" {
  value = 6379
}
# --- Add to modules/data/outputs.tf ---

output "assets_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.assets.id
}

output "assets_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.assets.arn
}

# --- Add to modules/data/outputs.tf ---

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  value       = aws_dynamodb_table.app_table.name
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table"
  value       = aws_dynamodb_table.app_table.arn
}

# --- Add to modules/data/outputs.tf ---

output "athena_database_name" {
  description = "The name of the Athena database"
  value       = aws_athena_database.logs.name
}

output "athena_workgroup_name" {
  description = "The name of the Athena workgroup"
  value       = aws_athena_workgroup.main.name
}

output "athena_results_bucket_id" {
  description = "The S3 bucket ID where Athena results are stored"
  value       = aws_s3_bucket.athena_results.id
}