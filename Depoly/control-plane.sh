# DNS_UPSTREAM="100.100.100.100"

# microk8s enable community
microk8s enable dashboard
microk8s enable cert-manager
microk8s enable registry
microk8s enable rbac
microk8s enable metallb:10.64.140.43-10.64.140.49,192.168.0.105-192.168.0.111

microk8s kubectl get all --all-namespaces


### Update CoreDNS to use custom upstream DNS ###
# echo "🔧 Setting CoreDNS upstream DNS to $DNS_UPSTREAM"
# microk8s kubectl -n kube-system get configmap coredns -o yaml \
#   | sed "s/forward \. .*/forward . $DNS_UPSTREAM/" \
#   | microk8s kubectl apply -f -

# echo "🔄 Restarting CoreDNS..."
# microk8s kubectl -n kube-system rollout restart deployment coredns


# Expose dashboard with Loadbalencer and not dashboard-proxy (meant for local development)
cat <<EOF | microk8s kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: kubernetes-dashboard-lb
  namespace: kube-system
spec:
  type: LoadBalancer
  externalIPs:
  - $(tailscale ip -4 | head -n1)
  ports:
  - port: 9901
    targetPort: 443
    protocol: TCP
    name: https
  selector:
    k8s-app: kubernetes-dashboard
EOF

# Ensure admin-user exists for dashboard
echo "Ensuring 'admin-user' exists for dashboard..."
cat <<EOF | microk8s kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kube-system
EOF

# Get Admin user Token
echo "Fetching dashboard admin token..."
SECRET_NAME=$(microk8s kubectl -n kube-system get secret | grep admin-user | awk '{print $1}' || true)
if [ -z "$SECRET_NAME" ]; then
  echo "Admin user secret not found."
  exit 1
fi

microk8s kubectl -n kube-system describe secret "$SECRET_NAME" | grep 'token:'

# Setup Hetzner S3
# Write Hetzner secret
cat <<EOF | microk8s kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: hcloud
  namespace: kube-system
stringData:
  token: $HETZNER_S3_TOKEN
EOF

# Add S3 CSI Driver
microk8s helm repo add hcloud https://charts.hetzner.cloud
microk8s helm repo update hcloud
microk8s helm install hcloud-csi hcloud/hcloud-csi -n kube-system

# Write StorageClass and PVC
cat <<EOF > ./hetzner_pvc.yml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: hcloud-volumes
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: csi.hetzner.cloud
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
reclaimPolicy: delete
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: hetzner-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 500Gi
  storageClassName: hcloud-volumes
EOF
microk8s kubectl apply -f ./hetzner_pvc.yml

# Apply ingress controller
echo "Adding Contour (Ingress Controller)"
microk8s kubectl apply -f https://projectcontour.io/quickstart/contour.yaml

# Deploy Portainer
echo "Adding Portainer"
microk8s helm repo add portainer https://portainer.github.io/k8s/
microk8s helm repo update

microk8s helm upgrade --install --create-namespace -n portainer portainer portainer/portainer \
    --set service.type=LoadBalancer \
    --set tls.force=false \
    --set image.tag=lts \
    --set service.httpNodePort=9902 \
    --set persistence.storageClass=hcloud-volumes


microk8s enable cis-hardening