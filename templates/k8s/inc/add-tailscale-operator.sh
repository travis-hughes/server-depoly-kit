cat <<EOF | microk8s kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: tailscale-auth
  namespace: tailscale
stringData:
  token: $TAILSCALE_SECRET
EOF

helm repo add tailscale https://pkgs.tailscale.com/helmcharts
helm repo update

helm upgrade --install tailscale-operator tailscale/tailscale-operator \
  --namespace=tailscale \
  --create-namespace \
  --set-string oauth.clientId=$TAILSCALE_CLIENT_ID \
  --set-string oauth.clientSecret=$TAILSCALE_CLIENT_SECRET \
  --wait



echo "\n Applying Ingress's for Tailscale Operator"

cat <<EOF | microk8s kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kube-dashboard
  namespace: kube-system
  annotations:
    tailscale.com/funnel: "true"
spec:
  ingressClassName: tailscale
  defaultBackend:
    service:
      name: dashboard
      port:
        number: 443
EOF