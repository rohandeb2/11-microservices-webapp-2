#!/bin/bash

# Root folder
ROOT="terraform-aws-boutique"

# Array of directories
dirs=(
  "$ROOT/environments/dev"
  "$ROOT/environments/prod"
  "$ROOT/modules/networking"
  "$ROOT/modules/security"
  "$ROOT/modules/compute"
  "$ROOT/modules/data"
  "$ROOT/modules/messaging"
  "$ROOT/modules/observability"
  "$ROOT/global/iam-users"
  "$ROOT/scripts"
)

# Array of files with paths
files=(
  "$ROOT/environments/dev/main.tf"
  "$ROOT/environments/dev/variables.tf"
  "$ROOT/environments/dev/terraform.tfvars"
  "$ROOT/environments/dev/backend.conf"
  "$ROOT/environments/prod/main.tf"
  "$ROOT/environments/prod/variables.tf"
  "$ROOT/environments/prod/terraform.tfvars"
  "$ROOT/environments/prod/backend.conf"

  "$ROOT/modules/networking/main.tf"
  "$ROOT/modules/networking/route53.tf"
  "$ROOT/modules/networking/cloudfront.tf"
  "$ROOT/modules/networking/variables.tf"
  "$ROOT/modules/networking/outputs.tf"

  "$ROOT/modules/security/main.tf"
  "$ROOT/modules/security/iam.tf"
  "$ROOT/modules/security/kms.tf"
  "$ROOT/modules/security/secrets.tf"
  "$ROOT/modules/security/acm.tf"

  "$ROOT/modules/compute/main.tf"
  "$ROOT/modules/compute/fargate.tf"
  "$ROOT/modules/compute/ecr.tf"
  "$ROOT/modules/compute/alb.tf"
  "$ROOT/modules/compute/variables.tf"

  "$ROOT/modules/data/main.tf"
  "$ROOT/modules/data/s3.tf"
  "$ROOT/modules/data/dynamodb.tf"
  "$ROOT/modules/data/athena.tf"

  "$ROOT/modules/messaging/main.tf"
  "$ROOT/modules/messaging/eventbridge.tf"

  "$ROOT/modules/observability/main.tf"
  "$ROOT/modules/observability/xray.tf"
  "$ROOT/modules/observability/variables.tf"

  "$ROOT/global/iam-users/.gitkeep"
  "$ROOT/scripts/.gitkeep"
  "$ROOT/.gitignore"
  "$ROOT/Makefile"
  "$ROOT/README.md"
)

# Create directories
for dir in "${dirs[@]}"; do
  mkdir -p "$dir"
done

# Create files
for file in "${files[@]}"; do
  touch "$file"
done

echo "Terraform project structure created successfully at '$ROOT/'"
