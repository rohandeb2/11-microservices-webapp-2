# ... (Your variables at the top)

# Senior Tip: Ensure we have the Cert ARN from Terraform before proceeding
CERT_ARN=$(terraform -chdir=./terraform-aws-boutique/environments/dev output -raw certificate_arn 2>/dev/null)

if [ -z "$CERT_ARN" ]; then
  echo "ERROR: Certificate ARN not found. Did you run 'terraform apply'?"
  exit 1
fi

for SERVICE in "${SERVICES[@]}"; do
  echo "--> Deploying $SERVICE..."
  
  # Ensure adservice uses v6, others use latest
  TAG=$([ "$SERVICE" == "adservice" ] && echo "v6" || echo "latest")

  # DYNAMIC REPO FIX (No more hardcoded IDs!)
  REPO="${ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com/boutique-app/$SERVICE"

  echo "    [Config] Repo: $REPO | Tag: $TAG"

  # PRO TIP: Passing the Cert ARN dynamically to the Ingress
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
    --wait --timeout 15m0s --atomic
done