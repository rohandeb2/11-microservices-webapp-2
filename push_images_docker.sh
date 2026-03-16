#!/bin/bash
# Push Images Script for Online Boutique & AI Tools

# 1. Define Variables
REGION="ap-south-1"
ACCOUNT_ID="889501007925"
ECR_BASE="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
REPO_PREFIX="boutique-app"

# Authenticate with ECR (Crucial step often missed)
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_BASE

# 2. List of core microservices (in src/)
SERVICES=("adservice" "cartservice" "checkoutservice" "currencyservice" "emailservice" "frontend" "loadgenerator" "paymentservice" "productcatalogservice" "recommendationservice" "shippingservice")

# 3. List of AI Tools (in tools/)
AI_TOOLS=("ai-alert-summarizer" "ai-analyzer" "ai-deployment-analyzer" "ai-predictive-scaler")

# --- Loop Through Core Services ---
for SERVICE in "${SERVICES[@]}"; do
    echo "🚀 Processing Microservice: $SERVICE..."
    
    cd src/$SERVICE || continue
    docker build -t $SERVICE .
    docker tag ${SERVICE}:latest ${ECR_BASE}/${REPO_PREFIX}/${SERVICE}:latest
    docker push ${ECR_BASE}/${REPO_PREFIX}/${SERVICE}:latest
    cd ../..
done

# --- Loop Through AI Tools ---
for TOOL in "${AI_TOOLS[@]}"; do
    echo "🧠 Processing AI Tool: $TOOL..."
    
    cd tools/$TOOL || continue
    docker build -t $TOOL .
    docker tag ${TOOL}:latest ${ECR_BASE}/${REPO_PREFIX}/${TOOL}:latest
    docker push ${ECR_BASE}/${REPO_PREFIX}/${TOOL}:latest
    cd ../..
done

echo "✅ All 11 microservices and 4 AI tools pushed to ECR successfully!"

# #!/bin/bash
# # Push Images Script for Online Boutique

# # 1. Define Variables
# REGION="ap-south-1"
# ACCOUNT_ID="889501007925"
# REPO_PREFIX="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/boutique-app"

# # 2. List of microservices (matches your folder names in src/)
# SERVICES=("adservice" "cartservice" "checkoutservice" "currencyservice" "emailservice" "frontend" "loadgenerator" "paymentservice" "productcatalogservice" "recommendationservice" "shippingservice")

# # 3. Loop through services
# for SERVICE in "${SERVICES[@]}"; do
#     echo "--------------------------------------"
#     echo "Processing $SERVICE..."
    
#     # Navigate to the service directory
#     cd src/$SERVICE
    
#     # Build the image
#     docker build -t $SERVICE .
    
#     # Tag for ECR
#     docker tag ${SERVICE}:latest ${REPO_PREFIX}/${SERVICE}:latest
    
#     # Push to ECR
#     docker push ${REPO_PREFIX}/${SERVICE}:latest
    
#     # Return to root
#     cd ../..
# done

# echo "All 11 microservices pushed to ECR successfully!"

# # Build and Push: Build your image and push it to your ECR repo (e.g., ai-alert-summarizer) and other ai tools also

