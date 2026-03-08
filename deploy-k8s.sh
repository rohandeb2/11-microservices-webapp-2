#!/bin/bash
# --- CEO Automation Script: Online Boutique (ALB Grouping Fix) ---

NAMESPACE="boutique-app"
CHART="./k8s-boutique-chart"
BOOTSTRAP_DIR="./k8s-cluster-bootstrap"
GROUP_NAME="boutique-group" # The key to fixing the 6-domain conflict

# 1. Initialize Infrastructure Governance
echo "Step 1: Applying Cluster Governance..."
kubectl apply -f $BOOTSTRAP_DIR/

# Senior Guard - Wait for ServiceAccount to exist
echo "Waiting for ServiceAccount to be ready..."
until kubectl get sa boutique-admin-sa -n $NAMESPACE &> /dev/null; do
  echo "  (Still waiting for boutique-admin-sa...)"
  sleep 2
done

# 2. Pre-Flight Check: External Secrets
echo "Step 2: Verifying Secret Store connectivity..."
kubectl wait --for=condition=Ready secretstore/aws-secrets-store -n $NAMESPACE --timeout=60s

# 3. Application Rollout Loop
echo "Step 3: Deploying Microservices via Helm..."
SERVICES=("adservice" "cartservice" "checkoutservice" "currencyservice" "emailservice" "frontend" "paymentservice" "productcatalogservice" "recommendationservice" "shippingservice")

for SERVICE in "${SERVICES[@]}"; do
  echo "--> Deploying $SERVICE..."
  
  # Ensure adservice uses v6, others use latest
  if [ "$SERVICE" == "adservice" ]; then
    TAG="v6"
  else
    TAG="latest"
  fi

  # Senior DevOps Fix: Force correct ECR path
  REPO="889501007925.dkr.ecr.ap-south-1.amazonaws.com/boutique-app/$SERVICE"

  echo "    [Config] Repo: $REPO | Tag: $TAG"

  # PRO TIP: We use --set-string for the group name to ensure Helm treats it as a single value
  helm upgrade --install $SERVICE $CHART \
    --namespace $NAMESPACE \
    -f env-values/$SERVICE.yaml \
    --set serviceName=$SERVICE \
    --set image.repository=$REPO \
    --set image.tag=$TAG \
    --set-string ingress.annotations."alb\.ingress\.kubernetes\.io/group\.name"="$GROUP_NAME" \
    --wait --timeout 15m0s --atomic
done

# 4. Final Verification
echo "Step 4: Verification Phase..."
kubectl get pods -n $NAMESPACE
echo "--- Final Ingress State ---"
kubectl get ingress -n $NAMESPACE