# --- modules/compute/ecr.tf ---

# 1. List of microservices from your project
locals { 
  services = [
    "frontend",
    "cartservice",
    "productcatalogservice",
    "currencyservice",
    "paymentservice",
    "shippingservice",
    "checkoutservice",
    "recommendationservice",
    "adservice",
    "emailservice",
    "loadgenerator"
  ]
}

# 2. Dynamic ECR Repository Creation
resource "aws_ecr_repository" "microservices" {
  for_each             = toset(local.services)
  name                 = "${var.project_name}/${each.key}"
  image_tag_mutability = "IMMUTABLE" # Industry standard: Prevents overwriting 'latest' tags

  image_scanning_configuration {
    scan_on_push = true # Mandatory for DevSecOps (Automatic vulnerability scanning)
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn # Using the CMK from our security module
  }

  tags = {
    Name = "${var.project_name}-${each.key}-ecr"
    Env  = var.environment
  }
}

# 3. Lifecycle Policy: Cleanup old images to save costs
resource "aws_ecr_lifecycle_policy" "cleanup" {
  for_each   = aws_ecr_repository.microservices
  repository = each.value.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1 # Priority of the rule (lower numbers are evaluated first)
      description  = "Keep only last 10 images"
      selection = {
        tagStatus     = "any" # This applies to all images regardless of tags. You can change this to 'tagged' and specify a tag prefix if you want to only keep images with certain tags.
        countType     = "imageCountMoreThan" # This means the rule will trigger when there are more than a certain number of images in the repository.
        countNumber   = 10
      }
      action = {
        type = "expire" # This means that when the rule is triggered, the excess images will be marked for deletion. AWS ECR will then automatically delete these images after a short period (usually within 24 hours).
      }
    }]
  })
}