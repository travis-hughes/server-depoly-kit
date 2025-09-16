microk8s disable ha-cluster --force

microk8s enable hostpath-storage
cat <<EOF | microk8s kubectl apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: local-system-storage
provisioner: microk8s.io/hostpath
reclaimPolicy: Delete
parameters:
  pvDir: /srv/k8s-storage
volumeBindingMode: WaitForFirstConsumer
EOF

microk8s enable cert-manager
microk8s enable rbac

HOST_PUBLIC_IP=$(tailscale ip -4 | head -n1)
microk8s enable metallb:"${HOST_PUBLIC_IP}-${HOST_PUBLIC_IP}"

# Ingress Controller
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml

microk8s enable dashboard
microk8s enable dashboard-proxy

microk8s kubectl get all --all-namespaces