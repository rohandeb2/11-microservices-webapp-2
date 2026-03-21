# --- Project General Settings ---
project_name = "boutique-app"
environment  = "dev"
aws_region   = "ap-south-1" # Mumbai

# --- Networking Settings ---
# Industry Standard: Match the architecture we built (1 VPC, 3 AZs, 9 Subnets)
vpc_cidr    = "10.0.0.0/16"
domain_name = "rohandevops.co.in" # Change this to your registered domain

# --- Compute / EKS Settings ---
# We use t3.medium for Dev to keep costs low while still running 11 services
eks_instance_type = "m7i-flex.large"
eks_node_count    = 2

# --- Security Settings ---
# Keep Security Hub enabled to maintain your posture even in dev
enable_security_hub = true

# --- Data Layer Settings ---
# Dev uses 2 nodes for Redis to save money compared to the 3 nodes in Prod
redis_node_type = "cache.t3.medium"
redis_node_count = 2

# --- Messaging & Observability ---
# We set this to true so we get alerts via email/Slack if dev crashes
enable_monitoring = true
