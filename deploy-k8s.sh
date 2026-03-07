#!/bin/bash
# --- CEO Automation Script: Online Boutique ---

NAMESPACE="boutique-app"
CHART="./k8s-boutique-chart"
BOOTSTRAP_DIR="./k8s-cluster-bootstrap"

# 1. Initialize Infrastructure Governance
echo "Step 1: Applying Cluster Governance (Quotas, Security, RBAC)..."
# Apply the bootstrap directory which contains namespace.yaml, resource-quota.yaml, etc.
kubectl apply -f $BOOTSTRAP_DIR/

# 2. Pre-Flight Check: External Secrets
# Ensures the secret sync is active before services try to pull DB passwords.
echo "Step 2: Verifying Secret Store connectivity..."
kubectl wait --for=condition=Ready secretstore/aws-secrets-store -n $NAMESPACE --timeout=60s

# 3. Application Rollout Loop
echo "Step 3: Deploying Microservices via Helm..."
SERVICES=("adservice" "cart-service" "checkoutservice" "currencyservice" "emailservice" "frontend" "loadgenerator" "paymentservice" "productcatalogservice" "redommendationservice" "shippingservice")

for SERVICE in "${SERVICES[@]}"; do
  echo "--> Deploying $SERVICE..."
  # Professional Helm execution with atomic flag (rolls back if it fails)
  helm upgrade --install $SERVICE $CHART \
    --namespace $NAMESPACE \
    -f env-values/$SERVICE.yaml \
    --set serviceName=$SERVICE \
    --wait --timeout 5m0s --atomic
done

# 4. Final Verification
echo "Step 4: Verification Phase..."
echo "--- Live Ingress Address (ALB) ---"
kubectl get ingress -n $NAMESPACE
