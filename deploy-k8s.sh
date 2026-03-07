#!/bin/bash
NAMESPACE="boutique-app"
CHART="./k8s-boutique-chart"

# Create namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# List of services to deploy
SERVICES=("adservice" "cart-service" "checkoutservice" "currencyservice" "emailservice" "frontend" "loadgenerator" "paymentservice" "productcatalogservice" "redommendationservice" "shippingservice")

for SERVICE in "${SERVICES[@]}"; do
  echo "Deploying $SERVICE..."
  helm upgrade --install $SERVICE $CHART \
    --namespace $NAMESPACE \
    -f env-values/$SERVICE.yaml
done
