HOST_PUBLIC_IP=$(tailscale ip -4 | head -n1)

microk8s disable ha-cluster --force

microk8s enable hostpath-storage
microk8s enable rbac
# microk8s enable cert-manager
microk8s enable dns:"$DNS_SERVER"
microk8s enable metallb:"${HOST_PUBLIC_IP}-${HOST_PUBLIC_IP}"
microk8s enable miniio # TODO: Add these options -c 100Gi -s ceph-xfs
microk8s enable dashboard
microk8s enable dashboard-proxy

# Ingress Controller
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml

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

microk8s kubectl get all --all-namespaceso