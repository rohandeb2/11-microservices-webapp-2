#!/bin/bash
# --- CEO Automation Script: Online Boutique ---

NAMESPACE="boutique-app"
CHART="./k8s-boutique-chart"
BOOTSTRAP_DIR="./k8s-cluster-bootstrap"
# Fix: Use a dynamic tag to bypass ECR immutability and apply Dockerfile fixes
CURRENT_TAG="v2" 

# 1. Initialize Infrastructure Governance
echo "Step 1: Applying Cluster Governance (Quotas, Security, RBAC)..."
kubectl apply -f $BOOTSTRAP_DIR/

# 2. Pre-Flight Check: External Secrets
echo "Step 2: Verifying Secret Store connectivity..."
kubectl wait --for=condition=Ready secretstore/aws-secrets-store -n $NAMESPACE --timeout=60s

# Senior DevOps Fix: Clear the shared identity to prevent "Ownership" metadata conflicts
# This allows the first Helm release in the loop to cleanly create and own the SA.
kubectl delete sa boutique-admin-sa -n $NAMESPACE --ignore-not-found

# 3. Application Rollout Loop
echo "Step 3: Deploying Microservices via Helm..."
SERVICES=("adservice" "cart-service" "checkoutservice" "currencyservice" "emailservice" "frontend" "loadgenerator" "paymentservice" "productcatalogservice" "redommendationservice" "shippingservice")

for SERVICE in "${SERVICES[@]}"; do
  echo "--> Deploying $SERVICE..."
  # Professional Helm execution:
  # 1. Added --set imageTag to inject your fixed Docker build
  # 2. Increased timeout to 15m because Fargate node provisioning is slow
  helm upgrade --install $SERVICE $CHART \
    --namespace $NAMESPACE \
    -f env-values/$SERVICE.yaml \
    --set serviceName=$SERVICE \
    --set imageTag=$CURRENT_TAG \
    --wait --timeout 15m0s --atomic
done

# 4. Final Verification
echo "Step 4: Verification Phase..."
echo "--- Pod Status ---"
kubectl get pods -n $NAMESPACE
echo "--- Live Ingress Address (ALB) ---"
kubectl get ingress -n $NAMESPACE