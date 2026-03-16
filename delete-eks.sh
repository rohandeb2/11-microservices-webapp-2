#!/usr/bin/env bash

NAMESPACE="boutique-app"

SERVICES=(
adservice
cartservice
checkoutservice
currencyservice
emailservice
frontend
paymentservice
productcatalogservice
recommendationservice
shippingservice
redis
)

echo "Deleting microservices..."

for SERVICE in "${SERVICES[@]}"; do
  helm uninstall $SERVICE -n $NAMESPACE 2>/dev/null || true
done

echo "Deleting bootstrap resources..."
kubectl delete -f k8s-cluster-bootstrap/ 2>/dev/null || true

echo "Deleting namespace..."
kubectl delete namespace $NAMESPACE 2>/dev/null || true

echo "Removing External Secrets..."
helm uninstall external-secrets -n external-secrets 2>/dev/null || true
kubectl delete namespace external-secrets 2>/dev/null || true

echo "Removing AWS Load Balancer Controller..."
helm uninstall aws-load-balancer-controller -n kube-system 2>/dev/null || true

echo "Removing Metrics Server..."
kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml 2>/dev/null || true

echo "Cleanup complete."

echo "Your cluster will still cost money in Amazon Elastic Kubernetes Service."
echo "Run this: eksctl delete cluster --name boutique-dev-cluster"


# # 1. Uninstall all Helm releases to clear the history
# SERVICES=("adservice" "cartservice" "checkoutservice" "currencyservice" "emailservice" "frontend" "loadgenerator" "paymentservice" "productcatalogservice" "recommendationservice" "shippingservice")

# for SERVICE in "${SERVICES[@]}"; do
#   helm uninstall $SERVICE -n boutique-app --wait || echo "$SERVICE already gone"
# done

# # 2. Delete the namespace (This wipes EVERYTHING: pods, services, and conflicted ingresses)
# kubectl delete namespace boutique-app

# # 3. Final Check (Wait until this returns 'Error from server (NotFound)')
# kubectl get ns boutique-app