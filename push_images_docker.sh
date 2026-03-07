#!/bin/bash
# Push Images Script for Online Boutique

# 1. Define Variables
REGION="ap-south-1"
ACCOUNT_ID="889501007925"
REPO_PREFIX="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/boutique-app"

# 2. List of microservices (matches your folder names in src/)
SERVICES=("adservice" "cartservice" "checkoutservice" "currencyservice" "emailservice" "frontend" "loadgenerator" "paymentservice" "productcatalogservice" "recommendationservice" "shippingservice")

# 3. Loop through services
for SERVICE in "${SERVICES[@]}"; do
    echo "--------------------------------------"
    echo "Processing $SERVICE..."
    
    # Navigate to the service directory
    cd src/$SERVICE
    
    # Build the image
    docker build -t $SERVICE .
    
    # Tag for ECR
    docker tag ${SERVICE}:latest ${REPO_PREFIX}/${SERVICE}:latest
    
    # Push to ECR
    docker push ${REPO_PREFIX}/${SERVICE}:latest
    
    # Return to root
    cd ../..
done

echo "All 11 microservices pushed to ECR successfully!"
