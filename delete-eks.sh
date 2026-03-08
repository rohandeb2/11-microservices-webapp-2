# 1. Uninstall all Helm releases to clear the history
SERVICES=("adservice" "cartservice" "checkoutservice" "currencyservice" "emailservice" "frontend" "loadgenerator" "paymentservice" "productcatalogservice" "recommendationservice" "shippingservice")

for SERVICE in "${SERVICES[@]}"; do
  helm uninstall $SERVICE -n boutique-app --wait || echo "$SERVICE already gone"
done

# 2. Delete the namespace (This wipes EVERYTHING: pods, services, and conflicted ingresses)
kubectl delete namespace boutique-app

# 3. Final Check (Wait until this returns 'Error from server (NotFound)')
kubectl get ns boutique-app