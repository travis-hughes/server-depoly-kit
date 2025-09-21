HOST_PUBLIC_IP=$(tailscale ip)

microk8s enable community
microk8s addons repo update core
microk8s addons repo update community

microk8s disable ha-cluster --force

microk8s enable hostpath-storage
microk8s enable ingress
microk8s enable rbac
# microk8s enable cert-manager
# microk8s enable dns:"$DNS_SERVER"
# TODO: Add these options -c 100Gi -s ceph-xfs
microk8s enable minio
microk8s enable metallb
microk8s enable dashboard

microk8s dashboard-proxy
echo "VPC Access to dashboard: $HOST_PUBLIC_IP:10443"

# Get Dashboard Token
token=$(microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
microk8s kubectl -n kube-system describe secret $token

# Ingress Controller
# kubectl apply -f https://projectcontour.io/quickstart/contour.yaml

microk8s kubectl get all --all-namespaces