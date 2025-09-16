microk8s disable dns --force

# microk8s enable community
microk8s enable dashboard
microk8s enable cert-manager
microk8s enable dns:100.100.100.100
microk8s enable registry
microk8s enable rbac
microk8s enable cis-hardening
microk8s enable metallb:"$(tailscale ip -4)"

microk8s kubectl get all --all-namespaces

TAILSCALE_IP=$(tailscale ip -4 | head -n1)

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
  - $TAILSCALE_IP
  ports:
  - port: 9901
    targetPort: 443
    protocol: TCP
    name: https
  selector:
    k8s-app: kubernetes-dashboard
EOF

echo "Waiting for dashboard to be available at https://$TAILSCALE_IP:9901 ..."
for i in {1..10}; do
    sleep 3
    if nc -zv "$TAILSCALE_IP" 9901 &>/dev/null; then
        echo "✅ Dashboard is now accessible at: https://$TAILSCALE_IP:9901"
        break
    else
        echo "Still waiting..."
    fi
done

echo "Fetching dashboard admin token..."
SECRET_NAME=$(microk8s kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
microk8s kubectl -n kube-system describe secret "$SECRET_NAME" | grep 'token:'

# Setup Hetzner S3
# Write Hetzner secret
cat <<EOF > ./deploy_tmp/hetzner_secrets.yml
apiVersion: v1
kind: Secret
metadata:
  name: hcloud
  namespace: kube-system
stringData:
  token: $HETZNER_S3_TOKEN
EOF

microk8s kubectl apply -f ./deploy_tmp/hetzner_secrets.yml
rm ./deploy_tmp/hetzner_secrets.yml

# Add S3 CSI Driver
microk8s helm repo add hcloud https://charts.hetzner.cloud
microk8s helm repo update hcloud
microk8s helm install hcloud-csi hcloud/hcloud-csi -n kube-system

# Write StorageClass and PVC
cat <<EOF > ./deploy_tmp/hetzner_pvc.yml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: hcloud-volumes
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: csi.hetzner.cloud
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
reclaimPolicy: Retain
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

# Apply ingress controller
echo "Adding Contour (Ingress Controller)"
microk8s kubectl apply -f https://projectcontour.io/quickstart/contour.yaml

# Deploy Portainer
echo "Adding Portainer"
microk8s helm repo add portainer https://portainer.github.io/k8s/
microk8s helm repo update

microk8s helm upgrade --install --create-namespace -n portainer portainer portainer/portainer \
    --set service.type=LoadBalancer \
    --set tls.force=true \
    --set image.tag=lts \
    --set service.httpNodePort=8001 \
    --set persistence.storageClass=hcloud-volumes