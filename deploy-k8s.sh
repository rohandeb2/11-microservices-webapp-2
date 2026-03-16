#!/usr/bin/env bash

set -euo pipefail

#############################################
# VARIABLES
#############################################

CLUSTER_NAME="boutique-dev-cluster"
REGION="ap-south-1"

NAMESPACE="boutique-app"

CHART="./k8s-boutique-chart"
BOOTSTRAP_DIR="./k8s-cluster-bootstrap"

GROUP_NAME="boutique-alb"

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

#############################################
# LOGGING
#############################################

log(){ echo -e "\033[1;32m[INFO]\033[0m $1"; }
warn(){ echo -e "\033[1;33m[WARN]\033[0m $1"; }
error(){ echo -e "\033[1;31m[ERROR]\033[0m $1"; }

#############################################
# TOOL CHECK
#############################################

log "Checking required tools..."

for tool in kubectl helm terraform aws eksctl; do
  if ! command -v $tool &> /dev/null; then
    error "$tool not installed"
    exit 1
  fi
done

#############################################
# CLUSTER CONNECTIVITY
#############################################

log "Checking Kubernetes connectivity..."

if ! kubectl cluster-info &> /dev/null; then
  error "kubectl cannot connect to cluster"
  exit 1
fi

#############################################
# AWS ACCOUNT
#############################################

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/boutique-admin-role"

#############################################
# CREATE NAMESPACE
#############################################

if ! kubectl get namespace $NAMESPACE &> /dev/null; then
  log "Creating namespace $NAMESPACE"
  kubectl create namespace $NAMESPACE
  kubectl create namespace logging
else
  warn "Namespace already exists"
fi

#############################################
# INSTALL METRICS SERVER
#############################################

log "Installing metrics server..."

if ! kubectl get deployment metrics-server -n kube-system &> /dev/null; then
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
else
  warn "Metrics server already installed"
fi

#############################################
# INSTALL EXTERNAL SECRETS
#############################################

log "Installing External Secrets..."

helm repo add external-secrets https://charts.external-secrets.io 2>/dev/null || true
helm repo update

if ! helm status external-secrets -n external-secrets &> /dev/null; then
  helm install external-secrets external-secrets/external-secrets \
  -n external-secrets --create-namespace
else
  warn "External secrets already installed"
fi

#############################################
# INSTALL AWS LOAD BALANCER CONTROLLER
#############################################

log "Installing AWS Load Balancer Controller..."

POLICY_NAME="AWSLoadBalancerControllerIAMPolicy"

if ! aws iam get-policy --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/$POLICY_NAME &> /dev/null; then

  log "Creating IAM policy"

  curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json

  aws iam create-policy \
  --policy-name $POLICY_NAME \
  --policy-document file://iam_policy.json

else
  warn "IAM policy already exists"
fi

if ! kubectl get sa aws-load-balancer-controller -n kube-system &> /dev/null; then

  log "Creating IAM ServiceAccount"

  eksctl create iamserviceaccount \
  --cluster $CLUSTER_NAME \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::$ACCOUNT_ID:policy/$POLICY_NAME \
  --approve

else
  warn "ServiceAccount already exists"
fi

helm repo add eks https://aws.github.io/eks-charts 2>/dev/null || true
helm repo update

if ! helm status aws-load-balancer-controller -n kube-system &> /dev/null; then

  log "Installing ALB controller"

  VPC_ID=$(aws eks describe-cluster \
  --name $CLUSTER_NAME \
  --region $REGION \
  --query "cluster.resourcesVpcConfig.vpcId" \
  --output text)

  helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=$REGION \
  --set vpcId=$VPC_ID

else
  warn "ALB controller already installed"
fi

#############################################
# APPLY BOOTSTRAP MANIFESTS
#############################################

if [ -d "$BOOTSTRAP_DIR" ]; then
  log "Applying cluster bootstrap manifests"

  kubectl apply -f $BOOTSTRAP_DIR
else
  warn "Bootstrap directory not found"
fi

#############################################
# GET CERTIFICATE ARN FROM TERRAFORM
#############################################

log "Fetching ACM certificate ARN..."

CERT_ARN=$(terraform -chdir=./terraform-aws-boutique/environments/dev output -raw certificate_arn 2>/dev/null || true)

if [[ -z "$CERT_ARN" ]]; then
  error "Certificate ARN not found. Run terraform apply."
  exit 1
fi

#############################################
# DEPLOY MICROSERVICES
#############################################

for SERVICE in "${SERVICES[@]}"; do

  log "Deploying $SERVICE"

  TAG="latest"

  if [[ "$SERVICE" == "adservice" ]]; then
    TAG="v6"
  fi

  REPO="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/boutique-app/${SERVICE}"

  helm upgrade --install $SERVICE $CHART \
  --namespace $NAMESPACE \
  -f env-values/$SERVICE.yaml \
  --set global.accountId=${ACCOUNT_ID} \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="${ROLE_ARN}" \
  --set serviceName=$SERVICE \
  --set image.repository=$REPO \
  --set image.tag=$TAG \
  --set ingress.annotations.certificateArn="$CERT_ARN" \
  --set-string ingress.annotations."alb\.ingress\.kubernetes\.io/group\.name"="$GROUP_NAME" \
  --wait \
  --timeout 15m \
  --atomic

done

#############################################
# VERIFY DEPLOYMENT
#############################################

log "Deployment complete"

log "Pods status:"
kubectl get pods -n $NAMESPACE

log "Ingress:"
kubectl get ingress -n $NAMESPACE

log "Application URL (ALB):"

kubectl get ingress -n $NAMESPACE \
-o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'

echo "🎉 All microservices deployed successfully! Access the application via the ALB URL above."

# # ... (Your variables at the top)

# # Senior Tip: Ensure we have the Cert ARN from Terraform before proceeding
# CERT_ARN=$(terraform -chdir=./terraform-aws-boutique/environments/dev output -raw certificate_arn 2>/dev/null)

# if [ -z "$CERT_ARN" ]; then
#   echo "ERROR: Certificate ARN not found. Did you run 'terraform apply'?"
#   exit 1
# fi

# for SERVICE in "${SERVICES[@]}"; do
#   echo "--> Deploying $SERVICE..."
  
#   # Ensure adservice uses v6, others use latest
#   TAG=$([ "$SERVICE" == "adservice" ] && echo "v6" || echo "latest")

#   # DYNAMIC REPO FIX (No more hardcoded IDs!)
#   REPO="${ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com/boutique-app/$SERVICE"

#   echo "    [Config] Repo: $REPO | Tag: $TAG"

#   # PRO TIP: Passing the Cert ARN dynamically to the Ingress
#   helm upgrade --install $SERVICE $CHART \
#     --namespace $NAMESPACE \
#     -f env-values/$SERVICE.yaml \
#     --set global.accountId=${ACCOUNT_ID} \
#     --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="${ROLE_ARN}" \
#     --set serviceName=$SERVICE \
#     --set image.repository=$REPO \
#     --set image.tag=$TAG \
#     --set ingress.annotations.certificateArn="$CERT_ARN" \
#     --set-string ingress.annotations."alb\.ingress\.kubernetes\.io/group\.name"="$GROUP_NAME" \
#     --wait --timeout 15m0s --atomic
# done