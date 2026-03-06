#!/bin/bash

# Define the 11 microservices
SERVICES=(
  "adservice" "cartservice" "checkoutservice" "currencyservice" 
  "emailservice" "frontend" "loadgenerator" "paymentservice" 
  "productcatalogservice" "recommendationservice" "shippingservice"
)

# Base directory
ROOT="kubernetes"

echo "🚀 Starting K8s Industrial Standard Scaffolding..."

# 1. Create Base Folders for each service
for SVC in "${SERVICES[@]}"; do
  DIR="$ROOT/base/$SVC"
  mkdir -p "$DIR"
  
  # Create the 7 standard files for each microservice
  touch "$DIR/deployment.yml"
  touch "$DIR/service.yml"
  touch "$DIR/service-account.yml"
  touch "$DIR/hpa.yml"
  touch "$DIR/pdb.yml"
  touch "$DIR/network-policy.yml"
  touch "$DIR/configMap.yml"
  touch "$DIR/kustomization.yml"
  
  echo "✅ Created base for: $SVC"
done

# 2. Create Global Networking
mkdir -p "$ROOT/base/networking"
touch "$ROOT/base/networking/ingress.yml"
touch "$ROOT/base/networking/certificate.yml"

# 3. Create Overlays - DEV
mkdir -p "$ROOT/overlays/dev/patches"
touch "$ROOT/overlays/dev/namespace.yml"
touch "$ROOT/overlays/dev/resource-quota.yml"
touch "$ROOT/overlays/dev/limit-range.yml"
touch "$ROOT/overlays/dev/external_secret.yml"
touch "$ROOT/overlays/dev/secret_store.yml"
touch "$ROOT/overlays/dev/patches/low-resource-patch.yml"
touch "$ROOT/overlays/dev/kustomization.yaml"

# 4. Create Overlays - PROD
mkdir -p "$ROOT/overlays/prod"
touch "$ROOT/overlays/prod/namespace.yml"
touch "$ROOT/overlays/prod/resource-quota.yml"
touch "$ROOT/overlays/prod/cluster-role.yml"
touch "$ROOT/overlays/prod/cluster-role-binding.yml"
touch "$ROOT/overlays/prod/storage-class.yml"
touch "$ROOT/overlays/prod/pvc.yml"
touch "$ROOT/overlays/prod/vpa.yml"
touch "$ROOT/overlays/prod/service_monitor.yml"
touch "$ROOT/overlays/prod/k8sRequiredLabels.yml"
touch "$ROOT/overlays/prod/kustomization.yaml"

echo "📂 All directories and files have been initialized!"
echo "💡 Next step: Fill in the content for each YAML."