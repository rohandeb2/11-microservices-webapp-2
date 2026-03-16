# --- modules/data/main.tf ---

# 1. ElastiCache Subnet Group
# This defines which subnets (Private-DB) the Redis cluster will live in
resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.project_name}-redis-subnet-group"
  subnet_ids = var.private_db_subnet_ids
}

# 2. Security Group for Redis
resource "aws_security_group" "redis_sg" {
  name        = "${var.project_name}-redis-sg"
  description = "Allow EKS nodes to access Redis"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.eks_nodes_sg_id] # Best Practice: Only allow traffic from EKS nodes
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic (Redis needs to communicate with EKS nodes and AWS services)
  }

  tags = {
    Name = "${var.project_name}-redis-sg"
  }
}

# 3. ElastiCache Redis Cluster (Replaces local redis-cart)
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "${var.project_name}-cart-cache" # This is the unique identifier for the Redis cluster. It should be descriptive and include the project name and purpose (e.g., "cart-cache").
  description = "Redis cluster for cartservice"
  node_type                     = "cache.t3.medium"
  port                          = 6379
  parameter_group_name          = "default.redis7"
  subnet_group_name             = aws_elasticache_subnet_group.redis.name
  security_group_ids            = [aws_security_group.redis_sg.id]
  
  # High Availability Settings
  automatic_failover_enabled = true
  multi_az_enabled           = true
  num_cache_clusters         = var.environment == "prod" ? 3 : 2 # More nodes in prod for better performance and availability, fewer in dev to save costs.

  # Security Settings
  at_rest_encryption_enabled    = true
  transit_encryption_enabled    = true
  kms_key_id                    = var.kms_key_arn # Using our Security Module Key
  
  tags = {
    Name = "${var.project_name}-redis"
    Env  = var.environment
  }
}